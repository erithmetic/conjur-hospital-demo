# Conjur Demo

This demo demonstrates how the conjur CLI is used to set up a sample permissions model for a hospital. 

## Installation

Clone this repo:

    $ git clone http://github.com/conjurinc/conjr-demo.git
    $ cd conjr-demo

Install the gems:

    $ bundle

Configure your Conjur credentials according to [http://developer.conjur.net/guides/client-install.html](http://developer.conjur.net/guides/client-install.html)

## Usage

The script is demonstrated by a series of cucumber features. After your Conjur
credentials are configured, run:

    $ cucumber

You will see a series of actions run that verify the permissions are set up
correctly.
