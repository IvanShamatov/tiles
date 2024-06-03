Xephyr -ac -br -noreset -screen 1280x720 :100 &
export DISPLAY=:100
ruby main.rb
xeyes
