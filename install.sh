gg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB
\curl -sSL https://get.rvm.io | bash -s stable

source ~/.rvm/scripts/rvm

sudo yum install -y nodejs npm --enablerepo=epel

rvm install 2.4.1 
rvm gemset create aws-demo
rvm gemset use aws-demo
gem install bundler

cd ..
cd -
bundle