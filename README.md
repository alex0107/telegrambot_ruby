# telegrambot_ruby
A TelegramBot with ruby running on Debian Linux

On Debian:

apt-get install rubygems

then clone this repository.
You could use screen or tmux to run this bot on your Linux-System.

So now you have to install bundle:

gem install bundle

after this go in the cloned directory and type:

bundle install

Now open telegram.rb with an editor and insert your Bot-Token.
On line 66 replace !!your_token!! with your token.
To run the bot type:

bundle exec ruby telegram.rb

Have fun!

(Optional)

Install imagemagick and fortune with

apt-get install imagemagick fortune