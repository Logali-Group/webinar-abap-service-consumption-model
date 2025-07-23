@Metadata.allowExtensions: true
@EndUserText.label: '###GENERATED Core Data Service Entity'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@ObjectModel.sapObjectNodeType.name: 'ZTRAVL_LGL'
define root view entity ZC_TRAVL_LGL
  provider contract transactional_query
  as projection on ZR_TRAVL_LGL
{
  key TravelUuid,
      TravelId,
      AgencyId,
      
      @ObjectModel.text.element: [ 'CustomerName' ]
      @Consumption.valueHelpDefinition: [{ entity: { name : '/DMO/I_Customer_StdVH',
                                                    element : 'CustomerID' },
                                           useForValidation: true }]

      CustomerId,
      CustomerName,
      BeginDate,
      EndDate,
      BookingFee,
      TotalPrice,
      @Semantics.currencyCode: true
      CurrencyCode,
      Description,
      OverallStatus,
      LocalCreatedBy,
      LocalCreatedAt,
      LocalLastChangedBy,
      LocalLastChangedAt,
      LastChangedAt

}
