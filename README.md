# EIPiD
![Build status](https://circleci.com/gh/quickleft/eipid-server.png?circle-token=2d51cac0cfa3e656353ff6601becc4de346e8c9d)

Electronic Identification Platform

API Documentation
=================

### POST /api/v1/authorize.json
Returns an auth token when given valid credentials.

Request: `{ phone_number: '123-456-7890', password: 'abc123' }`

Response: `{ auth_token: '789zyx' }`

Returns a 401 error if the user is unauthorized.

If the user is pending, the response will be
`{ auth_token: "", onboarding: "/path/to/onboard?onboarding_token=abc123", onboarding_token: "abc123" }`

### GET /api/v1/require_pin.json
Tells you whether or not the server requires passwords for authentication.

Response `{ require_pin: 'true' }`

### POST /api/v1/cardholder/redeem.json
Redeems the amount of benefits specified by `benefit_redemption_count`

Requires an auth token in the header: `{ authorization: 'myToken' }`

Request: `{ benefit_redemption_count: 5 }`

Response: `{ success: 'Benefits accepted', count: 40 }`

(Count is `total_redeemable_benefit_allotment` remaining after the benefits have been redeemed)

### GET /api/v1/cardholder.json
Shows a cardholder with nested photo and cards. Requires an auth token in the header: `Authorization: 'Token token="myToken"'`

Response:

        {
            id: 123,
            phone_number: '303-555-1212',
            first_name: 'John',
            last_name: 'Smith',
            photo: {
                    full: 'photos/full.jpg',
                    mobile_large: 'photos/mobile_large.jpg',
                    mobile_small: 'photos/mobile_small.jpg'
                }
            cards: [
                {
                    id: 456,
                    card_level: {
                        name: 'name',
                        benefits: [
                            {
                                description: 'description',
                                start_date: 'timestamp',
                                end_date: 'timestamp'
                            }
                        ],
                        promotions: [
                            {
                                title: 'title',
                                description: 'description',
                                start_date: 'timestamp',
                                end_date: 'timestamp',
                                description_auto_linked: 'This is the <a href="http://google.com/">description</a>',
                                active?: 'true',
                                short_url: 'short_url',
                                images: {
                                    full: 'photos/full.jpg',
                                    mobile_large: 'photos/mobile_large.jpg',
                                    mobile_small: 'photos/mobile_small.jpg'
                                }
                            }
                        ],
                        card_theme: {
                            name: 'name',
                            portrait_background: '/photos/portrait_background.jpg',
                            landscape_background: '/photos/landscape_background.jpg'
                        },
                        redeemable_benefit_name: {
                            singular: 'name',
                            plural: 'names'
                        }
                    },
                    venue: {
                        name: 'name',
                        time_zone: 'time_zone',
                        phone: '123-456-7890',
                        sender_number: '123-456-7890',
                        time_zone_offset: 'formatted_offset',
                        logos: {
                            full: 'photos/full.jpg',
                            mobile_large: 'photos/mobile_large.jpg',
                            mobile_small: 'photos/mobile_small.jpg'
                        }
                    },
                    total_redeemable_benefit_allotment: 33,
                    status: 'status',
                    benefits: [
                        {
                            description: 'description',
                            start_date: 'start_date',
                            end_date: 'end_date'
                        }
                    ]
                }
            ]
        }

### POST /api/v1/cardholder/complete_onboard.json
Before you call this, you must attempt to authorize with a phone number. If the cardholder is pending,
you will receive the onboarding token, which you can pass to this method.

Fill in the empty fields on the cardholder profile and activate the cardholder's account

Request: `{ cardholder: { onboarding_token: "abc123", first_name: "Bob", last_name: "Smith", photo: <data>, photo_cache: <data> }  }`

Response: `{ success: "Cardholder updated" }`
