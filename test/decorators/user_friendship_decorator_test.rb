require 'test_helper'

class UserFriendshipDecoratorTest < Draper::TestCase
	context "#friendship_state" do
		context "with a pending user friendship"  do
			setup do
				@user_friendship = create(:pending_user_friendship)
				@decorator = UserFriendshipDecorator.decorate(@user_friendship)
			end

			should "return Pending" do
				assert_equal "Pending", @decorator.friendship_state
			end
		end
		context "with a accepted user friendship"  do
			setup do
				@user_friendship = create(:accepted_user_friendship)
				@decorator = UserFriendshipDecorator.decorate(@user_friendship)
			end

			should "return Accepted" do
				assert_equal "Accepted", @decorator.friendship_state
			end
		end
	end
end