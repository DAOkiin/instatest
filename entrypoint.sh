#! /bin/sh

echo "Starting with UID : $(id -u) in $(pwd)"

if [[ ! -f "Gemfile"  && ! -f "Gemfile.lock" ]]; then
  echo "source 'https://rubygems.org'" > Gemfile \
  && echo "gem 'rails', '~> 5'" >> Gemfile \
  && touch Gemfile.lock \
  && gem install bundler\
  && bundle i --binstubs
fi

rm -rf tmp/pids

exec "$@"
