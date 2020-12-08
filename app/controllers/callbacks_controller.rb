class CallbacksController < Devise::OmniauthCallbacksController
    def github
        @user = User.from_omniauth(request.env["omniauth.auth"])
        puts "======----------github-----===========---"
        puts request.env["omniauth.auth"]
        puts @user.inspect
        sign_in_and_redirect @user
    end

    def recurse
        @user = User.from_omniauth(request.env["omniauth.auth"])
        puts "======------recurse------------"
        puts request.env["omniauth.auth"]
        puts @user.inspect
        sign_in_and_redirect @user
    end
end
