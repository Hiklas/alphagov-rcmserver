# RCM Server


## Overview

This is the code for the RCM prototype backend


## Running

###  Locally

You can install your favorite Rack server and use the relevant command to start the application.  Or you can simply run the following

```
rackup
```

which will read the config.ru file and launch the application.


### Heroku

The application has a Procfile and is configured to run under Heroku.


## Configuration

### Overview

The application is configured using a combination of environment variables and YAML files.


### Files

The application is configured using YAML files under the conf directory.  There is one for each environment: development, test, and production.
These files can contain environment variables using the following syntax

```
${<environment variable name>}
```

For example the production configuration contains the following

```
email:
  server:
    delivery_method: smtp
    smtp_server: ${MAILGUN_SMTP_SERVER}
    smtp_port: ${MAILGUN_SMTP_PORT}
    smtp_username: ${MAILGUN_SMTP_LOGIN}
    smtp_password: ${MAILGUN_SMTP_PASSWORD}
    # Hard-coded for now
    domain: alphagov-rcmserver.herokuapp.com

  address:
    from: ${EMAIL_SENDER}
    recipient: ${EMAIL_RECIPIENT}
    subject: ${EMAIL_SUBJECT}
```

The above makes extensive use of environment variables to configure the behaviour of the email delivery.
This has been done because the heroku hosting environment passes much of this configuration in the environment.
For the email addressing variable are used so that the recipient, sender, and subject can be changed without re-deploying the code.


### Environment

There are several environment variables that the application makes use of.  More can be added by including those in the configuration file.
Only the RACK_ENV environment variable is mandatory in the sense that it is always present for any RACK application.


#### RACK_ENV

This is a standard variable used to communicate the environment in which a RACK application is running.  The values this variable can take the following values

* development
* test
* production

For normal development work locally the value of this variable is obviously "development".  When running tests however it has been set to "test" in the Rakefile to force that configuration.

When running under heroku the value "production" us set.


#### EMAIL_SENDER

The sender address for the email message.  This is very likely to either be a dummy address or that of the recipient for testing.


#### EMAIL_RECIPIENT

The address that emailed data will be sent to.

NOTE: Make absolutely sure that you enter this correctly and seek (and obtain) permission from the person whom you will be sending this data to.


## Data

### JSON Format

The server presents a REST API that expects data to be sent in JSON format


#### Example

The example below shows data that the client would send to the server

```
{
  "caller": "RCM",
  "timestamp": "Thu Jun 11 2015 16:32:28 GMT+0100 (BST)",
  "values": {
    "form__identify-suspect": {
      "first-name": "Joe",
      "last-name": "Bloggs",
      "alternative-name--data": {
        "alternative-name--first-name": "",
        "alternative-name--last-name": ""
      },
      "helper--alternative-name": "No",
      "dob--data": {
        "dob--day": "",
        "dob--month": "",
        "dob--year": "",
        "dob--approx": "35"
      },
      "helper--dob": "No",
      "helper--address": "Yes",
      "address--data": {
        "address--line-1": "1",
        "address--line-2": "Terrace street",
        "address--town": "Hull",
        "address--county": "",
        "address--postcode": "HU11 1DS"
      },
      "nino--data": {
        "nino--ni-number": ""
      },
      "helper--nino": "No",
      "helper--telephone": "Yes",
      "telephone--data": {
        "telephone--mobile": "07780807070",
        "telephone--home": "",
        "telephone--other": ""
      },
      "helper--email": "Yes",
      "email--data": {
        "email--email": "joe@bloggs.com"
      },
      "social-media--info": "facebook"
    },
    "form__fraud-type": {
      "fraud-type": "workEarning"
    },
    "form__employment-suspect": {
      "work-location": "At home",
      "helper--self-employed": "Yes",
      "self-employed--data": {
        "self-employed--type-of-work": "He makes beer"
      },
      "work-duration": "years",
      "timings": "N\/A (he works from home)"
    },
    "form__other-information": {
      "additional-information": "He makes very nice beer that I buy while he's on benefit"
    }
  }
}
```
