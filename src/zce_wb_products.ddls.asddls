@EndUserText.label: 'Products'
@ObjectModel.query.implementedBy: 'ABAP:ZCL_CONSUME_EXT_ODATA_PRD'
define custom entity zce_wb_products
{
  key Product         : abap.char( 10 );
      ProductType     : abap.char( 2 );
      ProductCategory : abap.char( 40 );
      @Semantics.amount.currencyCode: 'Currency'
      Price           : abap.curr( 16, 2 );
      Currency        : abap.cuky( 5 );
      Supplier        : abap.char( 10 );

}
