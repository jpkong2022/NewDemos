########################################################################################################################
#!!
#! @input user_principal_name: Unique identifier of the user
#! @input force_change_password: Force the user to change his/her password first time he/she signs in
#!!#
########################################################################################################################
namespace: Alliance
flow:
  name: create_user_2
  inputs:
    - display_name: centos
    - mail_nick_name: centos
    - user_principal_name: centos@z1jfl.onmicrosoft.com
    - force_change_password: 'false'
  workflow:
    - ssh_command:
        do:
          io.cloudslang.base.ssh.ssh_command:
            - host: 172.31.75.22
            - command: whoami
            - username: centos
            - password:
                value: 'go.MF.admin123!'
                sensitive: true
        publish:
          - user: '${return_result}'
        navigate:
          - SUCCESS: genpassword
          - FAILURE: on_failure
    - genpassword:
        do:
          Alliance.genpassword: []
        publish:
          - passwd: '${password}'
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
                ''' % (user, user, user_principal_name, force_change_password, passwd)}
        publish:
          - json: '${return_result}'
        navigate:
          - FAILURE: FAILURE_1
          - SUCCESS: SUCCESS
  outputs:
    - json: '${json}'
  results:
    - SUCCESS
    - FAILURE_1
    - FAILURE
extensions:
  graph:
    steps:
      ssh_command:
        x: 40
        'y': 200
      genpassword:
        x: 160
        'y': 80
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
          10ee66c3-7e63-b297-1020-56b0eb16de10:
            targetId: f9ca98c4-3b22-08dc-b07e-53dfa4d7d54f
            port: SUCCESS
    results:
      SUCCESS:
        f9ca98c4-3b22-08dc-b07e-53dfa4d7d54f:
          x: 840
          'y': 240
      FAILURE_1:
        ece76b31-e874-2428-67f1-cd9b21fd41b8:
          x: 400
          'y': 400
