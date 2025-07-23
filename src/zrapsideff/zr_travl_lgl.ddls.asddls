@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
@EndUserText.label: '###GENERATED Core Data Service Entity'
@ObjectModel.sapObjectNodeType.name: 'ZTRAVL_LGL'
define root view entity ZR_TRAVL_LGL

  as select from ztravl_lgl as Travel

  association [0..1] to /DMO/I_Customer as _Customer on _Customer.CustomerID = $projection.CustomerId
{
  key travel_uuid           as TravelUuid,
      travel_id             as TravelId,
      agency_id             as AgencyId,
      customer_id           as CustomerId,
      customer_name         as CustomerName,
      begin_date            as BeginDate,
      end_date              as EndDate,
      @Semantics.amount.currencyCode: 'CurrencyCode'
      booking_fee           as BookingFee,
      @Semantics.amount.currencyCode: 'CurrencyCode'
      total_price           as TotalPrice,
      @Consumption.valueHelpDefinition: [ {
        entity.name: 'I_CurrencyStdVH',
        entity.element: 'Currency',
        useForValidation: true
      } ]
      currency_code         as CurrencyCode,
      description           as Description,
      overall_status        as OverallStatus,

      @Semantics.user.createdBy: true
      local_created_by      as LocalCreatedBy,
      @Semantics.systemDateTime.createdAt: true
      local_created_at      as LocalCreatedAt,
      @Semantics.user.localInstanceLastChangedBy: true
      local_last_changed_by as LocalLastChangedBy,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      local_last_changed_at as LocalLastChangedAt,
      @Semantics.systemDateTime.lastChangedAt: true
      last_changed_at       as LastChangedAt,

      _Customer

}
