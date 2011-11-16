puts# == Description
# Messages are between two users. We have three different keys in REDIS:
#
# [Messages]
#   Redis Key: "messages:A:B"
#
#   Since the messages between two users are the same, we keep only one copy.
#   To avoid duplicity, we store it with the key "messages:A:B", where A,B=user_id
#   and we make sure that A<B
#
#   Fields, Sorted set of:
#     - From     => user_id who sent the message (Always current_user)
#     - To       => user_id who receives the message
#     - Message  => content of the message
#     - Date     => message timestamp (automatically added)
#
# [Conversations]
#   Redis Key: "conversations:read:A"
#   Redis Key: "conversations:unread:A"
#
#   Each user has a copy of a conversation. A and B can have different conversation
#   status, for example:
#   - A can delete a conversation with B, but B should still see the messages
#   - B may have read the conversation, but A hasn't yet
#
#   We should keep a separate list that handles list of messages and 
#   if the messages are unread or not. Worth mentioning that we won't keep
#   track of read/unread for individual messages, but conversations.
#
#   Fields: Two Sorted Sets (read/unread) of user_ids for the other user in the conversation
#

#Authorization.current_user = User.last

class Message
  
  # == Description
  # Sends a message to a user:
  # - Creates a mesage object in redis
  # - Adds it to A and B's message list. B as unread
  # - Increases B unread counter
  # == Parameters
  # [:to]      User_id recipient of the message
  # [:message] String with the message
  #
  # Note. All messages are added automatically a Date field, with the time it was generated
  # == Usage
  # Message.to(2, "hi there!")
  def self.to(to_user, message_text)
    begin
      if User.find(to_user) and to_user.to_i != Authorization.current_user.id
        # Create message in redis
        m      = {:date     => DateTime.now.to_s}
        m.merge!({:from     => Authorization.current_user.id})
        m.merge!({:to       => to_user} )
        m.merge!({:message  => message_text})
        REDIS.zadd(Message.MessageKey(to_user), Message.score, m.to_json)

        # Add conversation to Sender
        # If existing, it will override the value
        REDIS.sadd(Message.ConversationReadKey, to_user)

        # Removes from read and adds unread conversation to Receiver
        REDIS.srem(Message.ConversationReadKey(to_user),   Authorization.current_user.id)
        REDIS.sadd(Message.ConversationUnreadKey(to_user), Authorization.current_user.id)

        return true
      else
        return false
      end
    rescue Exception => e
      return false
    end
  end
    
  # == Description
  # Returns an array with all the messages between the current user and another user
  # - Marks the conversation as read
  # == Parameters
  # [:user]  User_id recipient of the message
  # == Usage
  # Message.messages_with(2)
  def self.messages_with(user)
    Message.mark_as_read(user)
    return REDIS.zrange(Message.MessageKey(user), 0, -1)
  end

  # == Description
  # Returns the last message between the current user and another user
  # == Parameters
  # [:user]  User_id recipient of the message
  # == Usage
  # Message.last_message_with(2)
  def self.last_message_with(user)
    return REDIS.zrange(Message.MessageKey(user), -1, -1)
  end
  
  # == Description
  # Returns all the conversations message between the current user and another users
  # == Usage
  # Message.conversations
  def self.conversations
    return REDIS.sunion(Message.ConversationReadKey, Message.ConversationUnreadKey)
  end
  
  # Return the number of unread conversations
  def self.unread_count
    return REDIS.scard Message.ConversationUnreadKey
  end
  
  # Deletes a conversation with a user
  # NOTE: Conversations are really never deleted, they are just "hidden"
  #       for both users. If they message again, they will see all the history
  def self.delete_conversation_with(user)
    # We check that the conversation exists
    if (REDIS.sismember Message.ConversationReadKey,   user) or
       (REDIS.sismember Message.ConversationUnreadKey, user)
       REDIS.srem Message.ConversationReadKey,   user
       REDIS.srem Message.ConversationUnreadKey, user
       return true
    else
      return false
    end
  end

  # Returns true if a conversation has been read
  def self.is_read?(user)
    return REDIS.sismember Message.ConversationReadKey, user
  end
  
  # Marks a conversation as read
  def self.mark_as_read(user)
    # We check that the conversation exists and is unread
    if (REDIS.sismember Message.ConversationUnreadKey, user)
      REDIS.smove Message.ConversationUnreadKey, Message.ConversationReadKey, user
      return true
    else
      return false
    end
  end
  
  # Marks a conversation as unread
  def self.mark_as_unread(user)
    # We check that the conversation exists and is read
    if (REDIS.sismember Message.ConversationReadKey user)
      REDIS.smove Message.ConversationReadKey, Message.ConversationUnreadKey, user
      return true
    else
      return false
    end
  end

private
  # Key for Messages
  def self.MessageKey(to)
    if Authorization.current_user.id < to.to_i
      "messages:#{Authorization.current_user.id}:#{to}"
    else
      "messages:#{to}:#{Authorization.current_user.id}"
    end
  end

  # Key for Read Conversations: sender
  def self.ConversationReadKey(user = Authorization.current_user.id)
    "conversations:read:#{user.to_s}"
  end

  # Key for Read Conversations: sender
  def self.ConversationUnreadKey(user = Authorization.current_user.id)
    "conversations:unread:#{user.to_s}"
  end
    
  # Helper method to generate the timestamp based on unix time
  def self.score
    DateTime.now.to_time.to_i
  end
end
