require 'spec_helper'

describe "Routing" do
  describe 'Sessions' do
    it 'should route properly' do
      { get: "/login" }.should route_to( controller: "sessions", action: "new" )
      { get: "/logout" }.should route_to( controller: "sessions", action: "destroy" )
      { delete: "/logout" }.should route_to( controller: "sessions", action: "destroy" )
    end
  end

  describe 'Admin' do
    it 'should route properly' do
      { get: "/admin" }.should route_to( controller: "admin/pages", action: "index" )
    end
  end

  describe 'Venue' do
    it 'should route properly' do
      { get: '/venue/signup' }.should route_to( controller: 'venues', action: 'new' )
      { get: '/venue' }.should route_to( controller: 'venues', action: 'show' )
    end
  end
end
