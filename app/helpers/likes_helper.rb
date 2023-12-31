module LikesHelper
  def likes_index_path(likeable)
    case likeable.class.to_s
    when "Comment"
      comment_likes_path(likeable)
    when "Post"
      post_likes_path(likeable)
    end
  end

  def like_sentence_helper(number_of_likes)
    if number_of_likes == 1
      "1 person likes this"
    else
      "#{number_of_likes} people like this"
    end
  end

  def like_path_for_likeable(likeable, type)
    send("#{type}_like_path".to_sym, likeable)
  end
end
