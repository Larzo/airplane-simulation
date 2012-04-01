# run:
# rackup faye.ru -E production -s thin

require 'faye'
 
bayeux = Faye::RackAdapter.new(:mount => '/faye', :timeout => 25)
bayeux.listen(9292)