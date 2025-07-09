class zcl_consume_ext_odata_prd definition
  public
  final
  create public .

  public section.

    interfaces if_rap_query_provider.
    interfaces if_oo_adt_classrun.

    constants mc_base_url type string value 'https://sapes5.sapdevcenter.com'.
    constants mc_relative_service_root type string value '/sap/opu/odata/sap/ZPDCDS_SRV/'.

    types t_business_data type zscm_wb_products=>tyt_sepmra_i_product_etype.
    types t_product_range type range of zscm_wb_products=>tys_sepmra_i_product_etype.

    types t_business_data_external type table of zce_wb_products.

  protected section.
  private section.

    methods get_products
      importing
        it_filter_cond   type if_rap_query_filter=>tt_name_range_pairs optional
        top              type i optional
        skip             type i optional
      exporting
        et_business_data type t_business_data
      raising
        /iwbep/cx_cp_remote
        /iwbep/cx_gateway
        cx_web_http_client_error
        cx_http_dest_provider_error.

endclass.



class zcl_consume_ext_odata_prd implementation.

  method if_oo_adt_classrun~main.

    data business_data type t_business_data.
    data filter_conditions type if_rap_query_filter=>tt_name_range_pairs.
    data range_table type if_rap_query_filter=>tt_range_option.

    range_table = value #( ( sign = 'I' option = 'GE' low = 'HT-1200' ) ).

    filter_conditions = value #( ( name = 'PRODUCT' range = range_table ) ).

    try.

        me->get_products(
          exporting
            it_filter_cond   = filter_conditions
            top              = 5
            skip             = 1
          importing
            et_business_data = business_data ).

        out->write( business_data ).

      catch cx_root into data(lx_exception).
        out->write( cl_message_helper=>get_latest_t100_exception( lx_exception )->if_message~get_longtext(  ) ).
    endtry.

  endmethod.

  method get_products.

    data: lo_filter_factory   type ref to /iwbep/if_cp_filter_factory,
          lo_filter_node      type ref to /iwbep/if_cp_filter_node,
          lo_root_filter_node type ref to /iwbep/if_cp_filter_node.

    data: lo_http_client  type ref to if_web_http_client,
          lo_client_proxy type ref to /iwbep/if_cp_client_proxy,

          lo_request      type ref to /iwbep/if_cp_request_read_list,
          lo_response     type ref to /iwbep/if_cp_response_read_lst.

    try.
        " Create http client
        data(lo_http_destination) = cl_http_destination_provider=>create_by_url( i_url = mc_base_url ).

        lo_http_client = cl_web_http_client_manager=>create_by_http_destination( lo_http_destination ).

        lo_client_proxy = /iwbep/cl_cp_factory_remote=>create_v2_remote_proxy(
          exporting
             is_proxy_model_key       = value #( repository_id       = 'DEFAULT'
                                                 proxy_model_id      = 'ZSCM_WB_PRODUCTS'
                                                 proxy_model_version = '0001' )
            io_http_client             = lo_http_client
            iv_relative_service_root   = mc_relative_service_root ).

        assert lo_http_client is bound.


        " Navigate to the resource and create a request for the read operation
        lo_request = lo_client_proxy->create_resource_for_entity_set( 'SEPMRA_I_PRODUCT_E' )->create_request_for_read( ).

        " Create the filter tree
        lo_filter_factory = lo_request->create_filter_factory( ).

        loop at it_filter_cond into data(filter_condition).

          lo_filter_node  = lo_filter_factory->create_by_range( iv_property_path     = filter_condition-name
                                                                it_range             = filter_condition-range ).

          if lo_root_filter_node is initial.
            lo_root_filter_node = lo_filter_node.
          else.
            lo_root_filter_node = lo_root_filter_node->and( lo_filter_node ).
          endif.

        endloop.


        if lo_root_filter_node is not initial.
          lo_request->set_filter( lo_root_filter_node ).
        endif.

        if top > 0.
          lo_request->set_top( top ).
        endif.

        lo_request->set_skip( skip ).

        " Execute the request and retrieve the business data
        lo_response = lo_request->execute( ).
        lo_response->get_business_data( importing et_business_data = et_business_data ).

      catch /iwbep/cx_cp_remote into data(lx_remote).
        " Handle remote Exception
        " It contains details about the problems of your http(s) connection

      catch /iwbep/cx_gateway into data(lx_gateway).
        " Handle Exception

      catch cx_web_http_client_error into data(lx_web_http_client_error).
        " Handle Exception
        raise shortdump lx_web_http_client_error.

      catch cx_http_dest_provider_error into data(lx_http_dest_provider_error).

    endtry.

  endmethod.

  method if_rap_query_provider~select.

    data business_data type t_business_data.
    data business_data_external type t_business_data_external.

    data(top) = io_request->get_paging(  )->get_page_size(  ).
    data(skip) = io_request->get_paging(  )->get_offset(  ).

    data(requested_fields) = io_request->get_requested_elements(  ).
    data(sort_order) = io_request->get_sort_elements(  ).

    try.

        data(filter_condition) = io_request->get_filter(  )->get_as_ranges(  ).

        me->get_products( exporting it_filter_cond   = filter_condition
                                    top              = conv i( top )
                                    skip             = conv i( skip )
                          importing et_business_data = business_data ).


        business_data_external = corresponding #( business_data mapping Product = product
                                                                       ProductType = product_type
                                                                       ProductCategory = product_category
                                                                       Price = price
                                                                       Currency = currency
                                                                       Supplier = supplier ).

        io_response->set_total_number_of_records( lines( business_data_external ) ).
        io_response->set_data( business_data_external ).

      catch cx_root into data(lx_exception).
        data(exeption_message) = cl_message_helper=>get_latest_t100_exception( lx_exception )->if_message~get_longtext(  ).
    endtry.

  endmethod.

endclass.
