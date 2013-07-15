require 'spec_helper'

describe ShortUrlCache do
  subject { ShortUrlCache }

  let(:client){ double('client') }

  before do
    Bitly.stub(:client).and_return(client)
    ShortUrlCache.cache={}
  end

  it "should call bitly if url not cached" do
    subject.cache.clear

    client.should_receive(:shorten).with(any_args()).and_return("http://sho.rt/1")
    subject.shorten('http://shouldnotbecached.com')
  end

  it "should call bitly if url cached AND skip_cache is true" do
    subject.cache['http://iamchached.com'] = "http://sho.rt/1"

    client.should_receive(:shorten).with(any_args()).and_return("http://sho.rt/1")
    subject.shorten('http://iamchached.com', skip_cache: true)
  end

  it "should not call bitly if cache has url" do
    subject.cache['http://iamchached.com'] = "http://sho.rt/1"

    client.should_not_receive(:shorten)
    subject.shorten('http://iamchached.com')
  end
end
