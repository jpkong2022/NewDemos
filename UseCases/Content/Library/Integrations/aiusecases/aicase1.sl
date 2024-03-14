########################################################################################################################
#!!
#! @input user_principal_name: Unique identifier of the user  
#! @input force_change_password: Force the user to change his/her password first time he/she signs in
#!!#
########################################################################################################################
namespace: aiusecases
version: '2.0'

flow:
  name: create_user
  inputs:
    - display_name: Test
    - mail_nick_name: Test
    - user_principal_name: Test@z1jfl.onmicrosoft.com
    - force_change_password: 'false'
  workflow:
    - genpassword:
        do:
          Alliance.genpassword: []
        publish:
          - password
        navigate:
          - SUCCESS: authenticate
    - authenticate:
        do:
          office365.auth.authenticate: []
        publish:
          - token
        navigate:
          - FAILURE: FAILURE_1
          - SUCCESS: http_graph_action
    - http_graph_action:
        do:
          office365._tools.http_graph_action:
            - url: /users
            - token: '${token}'
            - method: POST
            - body: |-
                ${'''
                {
                  "accountEnabled": true,
                  "displayName": "%s",
                  "mailNickname": "%s",
                  "userPrincipalName": "%s",
                  "passwordProfile" : {
                    "forceChangePasswordNextSignIn": %s,
                    "password": "%s"
                  }
                }
                ''' % (display_name, mail_nick_name, user_principal_name, force_change_password, password)}
        publish:
          - json: '${return_result}'
        navigate:
          - FAILURE: FAILURE_1
          - SUCCESS:
              next_step: SUCCESS
              ROI: '100'
  outputs:
    - json: '${json}'
  results:
    - SUCCESS
    - FAILURE_1
extensions:
  graph:
    steps:
      genpassword:
        x: 80
        'y': 200
      authenticate:
        x: 240
        'y': 200
        navigate:
          2d8ea526-af81-4889-e056-544a1bd111b3:
            targetId: ece76b31-e874-2428-67f1-cd9b21fd41b8
            port: FAILURE
      http_graph_action:
        x: 400
        'y': 200
        navigate:
          7855f798-8380-bd5f-8c6d-20d55decd8c5:
            targetId: ece76b31-e874-2428-67f1-cd9b21fd41b8
            port: FAILURE
          5d931a97-695e-fc96-7c02-d752dd0ed5c3:
            targetId: f9ca98c4-3b22-08dc-b07e-53dfa4d7d54f
            port: SUCCESS
    results:
      SUCCESS:
        f9ca98c4-3b22-08dc-b07e-53dfa4d7d54f:
          x: 840
          'y': 200
      FAILURE_1:
        ece76b31-e874-2428-67f1-cd9b21fd41b8:
          x: 400
          'y': 400


