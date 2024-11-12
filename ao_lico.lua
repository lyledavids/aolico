-- Initialize the posts and comments tables
local posts = {}
local comments = {}

-- Handler to create a new post
Handlers.add(
  "CreatePost",
  Handlers.utils.hasMatchingTag("Action", "CreatePost"),
  function (msg)
    local post = json.decode(msg.Data)
    local id = #posts + 1
    posts[id] = {
      id = id,
      author = msg.From,
      title = post.title,
      content = post.content,
      timestamp = os.time(),
      upvotes = 0,
      downvotes = 0
    }
    ao.send({Target = msg.From, Data = json.encode({success = true, message = "Post created", id = id})})
  end
)

-- Handler to create a new comment
Handlers.add(
  "CreateComment",
  Handlers.utils.hasMatchingTag("Action", "CreateComment"),
  function (msg)
    local comment = json.decode(msg.Data)
    local id = #comments + 1
    comments[id] = {
      id = id,
      postId = comment.postId,
      author = msg.From,
      content = comment.content,
      timestamp = os.time(),
      upvotes = 0,
      downvotes = 0
    }
    ao.send({Target = msg.From, Data = json.encode({success = true, message = "Comment created", id = id})})
  end
)

-- Handler to vote on a post
Handlers.add(
  "VotePost",
  Handlers.utils.hasMatchingTag("Action", "VotePost"),
  function (msg)
    local vote = json.decode(msg.Data)
    local post = posts[vote.postId]
    if post then
      if vote.direction == "up" then
        post.upvotes = post.upvotes + 1
      elseif vote.direction == "down" then
        post.downvotes = post.downvotes + 1
      end
      ao.send({Target = msg.From, Data = json.encode({success = true, message = "Vote recorded"})})
    else
      ao.send({Target = msg.From, Data = json.encode({success = false, message = "Post not found"})})
    end
  end
)

-- Handler to vote on a comment
Handlers.add(
  "VoteComment",
  Handlers.utils.hasMatchingTag("Action", "VoteComment"),
  function (msg)
    local vote = json.decode(msg.Data)
    local comment = comments[vote.commentId]
    if comment then
      if vote.direction == "up" then
        comment.upvotes = comment.upvotes + 1
      elseif vote.direction == "down" then
        comment.downvotes = comment.downvotes + 1
      end
      ao.send({Target = msg.From, Data = json.encode({success = true, message = "Vote recorded"})})
    else
      ao.send({Target = msg.From, Data = json.encode({success = false, message = "Comment not found"})})
    end
  end
)

-- Handler to get all posts
Handlers.add(
  "GetPosts",
  Handlers.utils.hasMatchingTag("Action", "GetPosts"),
  function (msg)
    ao.send({Target = msg.From, Data = json.encode(posts)})
  end
)

-- Handler to get comments for a specific post
Handlers.add(
  "GetComments",
  Handlers.utils.hasMatchingTag("Action", "GetComments"),
  function (msg)
    local postId = tonumber(msg.Data)
    local postComments = {}
    for _, comment in pairs(comments) do
      if comment.postId == postId then
        table.insert(postComments, comment)
      end
    end
    ao.send({Target = msg.From, Data = json.encode(postComments)})
  end
)

-- Handler for unknown actions
Handlers.add(
  "Unknown",
  function (msg)
    return true
  end,
  function (msg)
    ao.send({Target = msg.From, Data = json.encode({success = false, message = "Unknown action"})})
  end
)