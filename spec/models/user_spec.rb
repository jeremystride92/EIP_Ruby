require 'spec_helper'

describe User do
  it { should belong_to :venue }

  it { should validate_presence_of :email }
  it { should validate_uniqueness_of :email }
  it { should validate_presence_of :name }

  describe "Validations" do
    context "on a new user" do
      it "should not be valid without a password" do
        user = build :user, password: nil, password_confirmation: nil
        user.should_not be_valid
      end

      it "should be not be valid with a short password" do
        user = build :user, password: 'short', password_confirmation: 'short'
        user.should_not be_valid
      end

      it "should not be valid with a confirmation mismatch" do
        user = build :user, password: 'short', password_confirmation: 'long'
        user.should_not be_valid
      end
    end

    context "on an existing user" do
      let(:user) { create :user }

      it "should be valid with no changes" do
        user.should be_valid
      end

      it "should not be valid with an empty password" do
        user.password = user.password_confirmation = ""
        user.should_not be_valid
      end

      it "should be valid with a new (valid) password" do
        user.password = user.password_confirmation = "new password"
        user.should be_valid
      end
    end
  end

  describe "roles" do
    subject { create :user }

    it { should respond_to :roles }

    it 'should accept only valid roles' do
      subject.roles = [:venue_owner, :venue_manager, :clown]
      subject.roles.to_a.should =~ [:venue_owner, :venue_manager]
    end

    it { should validate_presence_of :roles }
  end

  describe "authentication" do
    it "should generate auth_token on create" do
      user = build :user
      user.auth_token.should be_nil
      user.save
      user.auth_token.should_not be_nil
    end

    it "should authenticate with correct password" do
      user = create :user
      user.authenticate(user.password).should_not == false
    end

    it "should not authenticate with incorrect password" do
      user = create :user
      user.authenticate('incorrect').should == false
    end
  end

  describe "#generate_unusable_password!" do
    let(:user) { build :user }

    it 'should change the password to some random stuff' do
      lambda {
        user.generate_unusable_password!
      }.should change(user, :password)

      user.password.length.should == 16
      user.password.should == user.password_confirmation
    end
  end

  describe "#generate_reset_token" do
    let(:user) { build :user }
    let(:test_time) { Time.current }

    before do
      DateTime.stub!(:current_time) { test_time }
    end

    it 'should set the reset token and date' do
      user.generate_reset_token
      user.reset_token.should be_present
      user.reset_token_date.to_i.should == test_time.to_i
    end
  end
end
