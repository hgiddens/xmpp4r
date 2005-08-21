#  XMPP4R - XMPP Library for Ruby
#  Copyright (C) 2004 Lucas Nussbaum <lucas@lucas-nussbaum.net>
#  Released under GPL v2 or later

require 'rexml/document'
require 'xmpp4r/xmlstanza'
require 'xmpp4r/jid'
require 'xmpp4r/iqquery.rb'
require 'xmpp4r/iqvcard.rb'
require 'digest/sha1'
include REXML

module Jabber
  ##
  # A class used to build/parse IQ requests/responses
  #
  class Iq < XMLStanza
    def initialize(type = nil, to = nil)
      super("iq")
      if not to.nil?
        set_to(to)
      end 
      if not type.nil?
        set_type(type)
      end 
    end

    ##
    # Returns the iq's query child, or nil
    # result:: [IqQuery]
    def query 
      s = nil
      each_element('query') { |e| s = e if s.nil? }
      s
    end

    ##
    # Returns the iq's query's namespace, or nil
    # result:: [String]
    def queryns 
      s = nil
      each_element('query') { |e| s = e.namespace if s.nil? }
      s
    end

    ##
    # Returns the iq's <vCard/> child, or nil
    # result:: [IqVcard]
    def vcard 
      s = nil
      each_element('vCard') { |e| s = e if s.nil? }
      s
    end

    ##
    # Create a new iq from a stanza
    def Iq.import(xmlstanza)
      # TODO : clean up. The should be a better way.
      Iq::new.import(xmlstanza)
    end

    ##
    # Add an element to the Iq stanza
    # xmlelement:: [REXML::Element] Element to add. <query/> elements will be converted to IqQuery
    def add(xmlelement)
      if xmlelement.kind_of?(REXML::Element) && (xmlelement.name == 'query')
        super(IqQuery::import(xmlelement))
      elsif xmlelement.kind_of?(REXML::Element) && (xmlelement.name == 'vCard') && (xmlelement.namespace == 'vcard-temp')
        super(IqVcard::import(xmlelement))
      else
        super(xmlelement)
      end
    end

    ##
    # Create a new Iq stanza with a query child
    def Iq.new_query(type = nil, to = nil)
      iq = Iq::new(type, to)
      query = IqQuery::new
      iq.add(query)
      iq
    end

    ##
    # Create a new jabber:iq:auth set Stanza.
    def Iq.new_authset(jid, password)
      iq = Iq::new('set')
      query = IqQuery::new
      query.add_namespace('jabber:iq:auth')
      query.add(Element::new('username').add_text(jid.node))
      query.add(Element::new('password').add_text(password))
      query.add(Element::new('resource').add_text(jid.resource)) if not jid.resource.nil?
      iq.add(query)
      iq
    end

    ##
    # Create a new jabber:iq:auth set Stanza for Digest authentication
    def Iq.new_authset_digest(jid, session_id, password)
      iq = Iq::new('set')
      query = IqQuery::new
      query.add_namespace('jabber:iq:auth')
      query.add(Element::new('username').add_text(jid.node))
      query.add(Element::new('digest').add_text(Digest::SHA1.new(session_id + password).hexdigest))
      query.add(Element::new('resource').add_text(jid.resource)) if not jid.resource.nil?
      iq.add(query)
      iq
    end

    ##
    # Create a new jabber:iq:roster get Stanza.
    #
    # IqQueryRoster is unused here because possibly not require'd
    def Iq.new_rosterget
      iq = Iq::new('get')
      query = IqQuery::new
      query.add_namespace('jabber:iq:roster')
      iq.add(query)
      iq
    end

    ##
    # Create a new jabber:iq:roster get Stanza.
    def Iq.new_browseget
      iq = Iq::new('get')
      query = IqQuery::new
      query.add_namespace('jabber:iq:browse')
      iq.add(query)
      iq
    end

    ##
    # Create a new jabber:iq:roster set Stanza.
    def Iq.new_rosterset
      iq = Iq::new('set')
      query = IqQuery::new
      query.add_namespace('jabber:iq:roster')
      iq.add(query)
      iq
    end

    ##
    # Create a new Iq stanza with a vCard child
    # type:: [String] or "get" if omitted
    def Iq.new_vcard(type = 'get', to = nil)
      iq = Iq::new(type, to)
      iq.add(IqVcard::new)
      iq
    end
  end
end