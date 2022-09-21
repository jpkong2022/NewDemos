namespace: Alliance
flow:
  name: ootb_operation
  workflow:
    - write_to_file:
        do:
          io.cloudslang.base.filesystem.write_to_file:
            - file_path: "c:\\temp\\out.txt"
            - text: hello
        navigate:
          - SUCCESS: SUCCESS
          - FAILURE: on_failure
  results:
    - SUCCESS
    - FAILURE
extensions:
  graph:
    steps:
      write_to_file:
        x: 160
        'y': 80
        navigate:
          812ffa80-aeea-ce80-6e13-2c2779dd879e:
            targetId: 59cc57d9-ca9d-fa34-9dd7-386d2ce5cf66
            port: SUCCESS
    results:
      SUCCESS:
        59cc57d9-ca9d-fa34-9dd7-386d2ce5cf66:
          x: 400
          'y': 80
