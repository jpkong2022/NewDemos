namespace: ai
flow:
name: delete_user1
inputs:
- token
- userIds
workflow:
- http_graph_action:
    do:
      office365._tools.http_graph_action:
        - url: '/users/{userIds}'
        - method: DELETE
        - token: '${token}'
    publish:
      - json: '${return_result}'
    navigate:
       - FAILURE: FAILURE
       - SUCCESS: SUCCESS
outputs:
  - json: '${json}'
results:
  - FAILURE
  - SUCCESS