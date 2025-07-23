class lhc_zr_travl_lgl definition inheriting from cl_abap_behavior_handler.
  private section.
    methods:
      get_global_authorizations for global authorization
        importing
        request requested_authorizations for Travel
        result result,
      action1 for modify
        importing keys for action Travel~action1.

    methods action2 for modify
      importing keys for action Travel~action2.

    methods action3 for modify
      importing keys for action Travel~action3.

    methods setCustomerName for determine on modify
      importing keys for Travel~setCustomerName.

    methods validateCustomer for validate on save
      importing keys for Travel~validateCustomer.
endclass.

class lhc_zr_travl_lgl implementation.
  method get_global_authorizations.
  endmethod.
  method action1.
  endmethod.

  method action2.
  endmethod.

  method action3.
  endmethod.

  method setCustomerName.

    data: update_travels type table for update zr_travl_lgl\\Travel,
          customers      type sorted table of /dmo/customer with unique key client customer_id.

    read entities of zr_travl_lgl in local mode
         entity Travel
         fields ( CustomerId )
         with corresponding #( keys )
         result data(travels).

    customers = corresponding #( travels discarding duplicates mapping customer_id = CustomerId except * ).

    check customers is not initial.

    select from /dmo/customer as ddbb
           inner join @customers as http_req on ddbb~customer_id eq http_req~customer_id
           fields ddbb~customer_id,
                  ddbb~first_name,
                  ddbb~last_name
          into table @data(customers_details).

    loop at travels into data(travel).

      data(customer_name) = |{ customers_details[ customer_id = travel-CustomerId ]-last_name } { customers_details[ customer_id = travel-CustomerId ]-first_name }|.

      append value #( %tky = travel-%tky
                      CustomerName = customer_name ) to update_travels.

    endloop.

    modify entities of zr_travl_lgl in local mode
           entity Travel
           update fields ( CustomerName )
           with update_travels.

  endmethod.

  method validateCustomer.
  endmethod.

endclass.
