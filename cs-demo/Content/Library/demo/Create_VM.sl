namespace: demo
flow:
  name: Create_VM
  inputs:
    - host: 10.0.46.10
    - username: "Capa1\\1297-capa1user"
    - password: Automation123
    - datacenter: Capa1 Datacenter
    - image: Ubuntu
    - folder: Students/Celalettin
    - prefix_list: '1-,2-,3-'
  workflow:
    - uuid:
        do:
          io.cloudslang.demo.uuid: []
        publish:
          - uuid: "${'celal-'+uuid}"
        navigate:
          - SUCCESS: substring
    - substring:
        do:
          io.cloudslang.base.strings.substring:
            - origin_string: '${uuid}'
            - end_index: '14'
        publish:
          - id: '${new_string}'
        navigate:
          - SUCCESS: clone_vm
          - FAILURE: FAILURE
    - clone_vm:
        parallel_loop:
          for: prefix in prefix_list
          do:
            io.cloudslang.vmware.vcenter.vm.clone_vm:
              - host: '${host}'
              - user: '${username}'
              - password:
                  value: '${password}'
                  sensitive: true
              - vm_source_identifier: name
              - vm_source: '${image}'
              - datacenter: '${datacenter}'
              - vm_name: '${prefix + id}'
              - vm_folder: '${folder}'
              - mark_as_template: 'false'
              - trust_all_roots: 'true'
              - x_509_hostname_verifier: allow_all
        navigate:
          - SUCCESS: power_on_vm
          - FAILURE: FAILURE
    - power_on_vm:
        parallel_loop:
          for: prefix in prefix_list
          do:
            io.cloudslang.vmware.vcenter.power_on_vm:
              - host: '${host}'
              - user: '${username}'
              - password:
                  value: '${password}'
                  sensitive: true
              - vm_identifier: name
              - vm_name: '${prefix+id}'
              - trust_all_roots: 'true'
              - x_509_hostname_verifier: allow_all
        navigate:
          - SUCCESS: wait_for_vm_info
          - FAILURE: FAILURE
    - wait_for_vm_info:
        parallel_loop:
          for: prefix in prefix_list
          do:
            io.cloudslang.vmware.vcenter.util.wait_for_vm_info:
              - host: '${host}'
              - password:
                  value: '${password}'
                  sensitive: true
              - vm_identifier: name
              - vm_name: '${prefix+id}'
              - datacenter: '${datacenter}'
              - trust_all_roots: 'true'
              - x_509_hostname_verifier: allow_all
        publish:
          - ip_list: '${str([str(x["ip"]) for x in branches_context])}'
        navigate:
          - SUCCESS: SUCCESS
          - FAILURE: FAILURE
  outputs:
    - iplist: '${ip_list}'
  results:
    - SUCCESS
    - FAILURE
extensions:
  graph:
    steps:
      uuid:
        x: 146
        y: 136
      substring:
        x: 156
        y: 252
        navigate:
          7617e67e-0b19-b8b5-19ab-001daeac5016:
            targetId: 663ea9f8-54ab-92f1-d192-38c7a5e7e040
            port: FAILURE
      clone_vm:
        x: 348
        y: 141
        navigate:
          a8c902b3-dc16-e37b-e093-01f0d5ae4a73:
            targetId: 663ea9f8-54ab-92f1-d192-38c7a5e7e040
            port: FAILURE
      power_on_vm:
        x: 498
        y: 143
        navigate:
          a21b1f70-1e23-5514-7206-a9133d92e905:
            targetId: 663ea9f8-54ab-92f1-d192-38c7a5e7e040
            port: FAILURE
      wait_for_vm_info:
        x: 637
        y: 142
        navigate:
          4d4eb945-5726-327a-ec18-f2dd6a9c4853:
            targetId: 663ea9f8-54ab-92f1-d192-38c7a5e7e040
            port: FAILURE
          b26a068e-f4bc-9437-9a6b-e847a6607935:
            targetId: 6801f065-dc28-15fa-94fd-169d205fdd4f
            port: SUCCESS
    results:
      SUCCESS:
        6801f065-dc28-15fa-94fd-169d205fdd4f:
          x: 629
          y: 340
      FAILURE:
        663ea9f8-54ab-92f1-d192-38c7a5e7e040:
          x: 428
          y: 337
