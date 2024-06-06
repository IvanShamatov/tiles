Xephyr -ac -br -noreset -screen 3000x2000 :100 &
export DISPLAY=:100
ruby main.rb
