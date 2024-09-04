class User < ApplicationRecord
  enum gender: [:Male, :Female]
end
