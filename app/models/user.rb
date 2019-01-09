class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :omniauthable

  def self.find_for_oauth(auth)
    user = User.where(uid: auth.uid, provider: auth.provider).first
 
    unless user
      user = User.create(
        uid:      auth.uid,
        provider: auth.provider,
        email:    User.dummy_email(auth),
        password: Devise.friendly_token[0, 20],
        image: auth.info.image,
        name: auth.info.name,
        nickname: auth.info.nickname,
        location: auth.info.location
      )
    end
 
    user
  end

  def self.facebook_from_omniauth(auth)
    user = User.where(email: auth.info.email).first
    if user
      return user
    else
      where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
        # userモデルが持っているカラムをそれぞれ定義していく
        user.email = auth.info.email
        user.password = Devise.friendly_token[0,20]
        user.name = auth.info.name
        user.image = auth.info.image
        user.uid = auth.uid
        user.provider = auth.provider
      end
    end
  end

  def self.find_for_google(auth)
    user = User.where(uid: auth.uid, provider: auth.provider).first
    unless user
      user = User.create(name:     'ユーザーネーム未設定',
                         provider: auth.provider,
                         email:    User.dummy_email(auth),
                         uid:      auth.uid,
                         token:    auth.credentials.token,
                         password: Devise.friendly_token[0, 20])
    end
    user
  end
  
  private
    def self.dummy_email(auth)
      "#{auth.uid}-#{auth.provider}@omniauthable.com"
    end
end
