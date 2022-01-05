@isTest
public with sharing class ExternalDataSourceProviderTest {
  /**
   * @description Test method to invoke ExternalDataSourceProvider class.
   **/
  @isTest static void provideShouldReturnFunctionalAndAuthenticationCapabilities() {
    ExternalDataSourceProvider providerObj = new ExternalDataSourceProvider();
    DataSource.ConnectionParams connectionParams = new DataSource.ConnectionParams();
    Test.startTest();
      List<DataSource.AuthenticationCapability> authenticationCapabilities =
          providerObj.getAuthenticationCapabilities();
      List<DataSource.Capability> capabilities = providerObj.getCapabilities();
      providerObj.getConnection(connectionParams);
    Test.stopTest();

    System.assert(authenticationCapabilities
        .contains(DataSource.AuthenticationCapability.ANONYMOUS));
    System.assert(capabilities.contains(DataSource.Capability.ROW_QUERY));
  }
}