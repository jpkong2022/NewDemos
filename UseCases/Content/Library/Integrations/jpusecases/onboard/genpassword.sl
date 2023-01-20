namespace: Integrations.jpusecases.onboard
operation:
  name: genpassword
  python_action:
    use_jython: false
    script: "import string\r\nimport random\r\ndef execute():\r\n\r\n    store = [] #It will contain passwords\r\n\r\n    char_length = random.randrange(2,5)\r\n\r\n    for i in range(char_length):# using string module to generate the password\r\n\r\n        cap = random.choice(string.ascii_uppercase)\r\n\r\n        store += cap\r\n\r\n        small = random.choice(string.ascii_lowercase)\r\n\r\n        store += small\r\n\r\n        digit = random.choice(string.digits)\r\n\r\n        store += digit\r\n\r\n        punct = random.choice(string.punctuation)\r\n\r\n        store += punct\r\n\r\n    random.shuffle(store)# Shuffling it\r\n\r\n    random.shuffle(store)# Shuffling it again \r\n   \r\n    word = \"\".join(store)\r\n\r\n    return {'password': word }"
  outputs:
    - password: '${password}'
  results:
    - SUCCESS
