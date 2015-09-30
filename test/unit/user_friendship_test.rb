require 'test_helper'

class UserFriendshipTest < ActiveSupport::TestCase
	should belong_to(:user)
	should belong_to(:friend)

	test "that creating a friendship works without raising an exception" do 
		assert_nothing_raised do
			UserFriendship.create user: users(:jack), friend: users(:john)
		end
	end 

	test "that creating a friendship based on user id and friend id works" do
    	UserFriendship.create user_id: users(:jack).id, friend_id: users(:jill).id
    	assert users(:jack).pending_friends.include?(users(:jill))
    end

    context "new instance" do
    	setup do
    		@user_friendship = UserFriendship.new user: users(:jack), friend: users(:john)
     	end

     	should "have a pending state" do
     		assert_equal 'pending', @user_friendship.state
		end
	end

	context "#send_request_email" do
    	setup do
    		@user_friendship = UserFriendship.create user: users(:jack), friend: users(:john)
    	end
   		should "send an email" do
   			assert_difference 'ActionMailer::Base.deliveries.size', 1 do
   				@user_friendship.send_request_email  		
   		end
	end
end

	context "#mutual_friendship" do
		setup do
			UserFriendship.request users(:jack), users(:john)
			@friendship1 = users(:jack).user_friendships.where(friend_id: users(:john).id).first
			@friendship2 = users(:john).user_friendships.where(friend_id: users(:jack).id).first		
		end

		should "accept the mutual friendship" do
			assert_equal @friendship2, @friendship1.mutual_friendship
		end
	end

	context "#accept_mutual_friendship!" do
		setup do

			UserFriendship.request users(:jack), users(:john)
		end

		should "accept the mutual friendship" do
			friendship1 = users(:jack).user_friendships.where(friend_id: users(:john).id).first
			friendship2 = users(:john).user_friendships.where(friend_id: users(:jack).id).first		
			
			friendship1.accept_mutual_friendship!
			friendship2.reload
			assert_equal 'accepted', friendship2.state
		end
	end

	context "#accept!" do
		setup do
			@user_friendship = UserFriendship.request users(:jack), users(:john)
		end

		should "set the state to accepted" do
			@user_friendship.accept!
			assert_equal "accepted", @user_friendship.state
		end

		should "send acceptance email" do
   			assert_difference 'ActionMailer::Base.deliveries.size', 1 do
   				@user_friendship.accept!  	
   			end
		end

		should "include friend in friend list" do
			@user_friendship.accept!
			users(:jack).friends.reload
			assert users(:jack).friends.include?(users(:john))
		end

		should "accept the mutual friendship" do
			@user_friendship.accept!
			assert_equal 'accepted', @user_friendship.mutual_friendship.state
		end
	end

	context ".request" do
		should "create two user friendships" do
			assert_difference 'UserFriendship.count', 2 do
				UserFriendship.request(users(:jack), users(:john))
			end
		end

		should "send request email" do
			assert_difference 'ActionMailer::Base.deliveries.size', 1 do
				UserFriendship.request(users(:jack), users(:john))
			end
		end
	end
end