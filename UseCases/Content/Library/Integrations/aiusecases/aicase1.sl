########################################################################################################################
#!!
#! @input user_principal_name: Unique identifier of the user  
#! @input force_change_password: Force the user to change his/her password first time he/she signs in
#!!#
########################################################################################################################
namespace: aiusecases
version: '2.0'

flow:
  name: query_asset_number
  namespace: my_namespace
  description: |
    This workflow queries Micro Focus Asset Manager to retrieve the asset number of a device based on its IP address.
  inputs:
    - name: ip_address
      required: true
      description: The IP address of the device to query.

  steps:
    - name: authenticate
      action: "http:authenticate"
      inputs:
        username: "your_username"
        password: "your_password"
        url: "https://asset_manager_url/authenticate"

    - name: query_device
      action: "http:execute"
      inputs:
        headers: {"Authorization": "Bearer ${authenticate.result.response_body['access_token']}"}
        method: "GET"
        url: "https://asset_manager_url/devices?ip=${ip_address}"

    - name: extract_asset_number
      action: "script:invoke"
      inputs:
        script: |
          return response['asset_number']

  outputs:
    - name: asset_number
      value: "${extract_asset_number.result}"
