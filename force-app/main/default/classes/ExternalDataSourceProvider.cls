/**
 * @description Extends the Datasoure.Provider base class to create a
 *     custom adapter for Salesforce Connect. The class informs
 *     Salesforce of the functional and authentication capabilities
 *     that are supported by or required to connect to an external system.
 **/
global with sharing class ExternalDataSourceProvider extends DataSource.Provider {
  public ExternalDataSourceProvider() {
  }

  /**
   * @description Declare the types of authentication that can be used to access the external
   *     system. Other authentication possibilities: Basic, Certificate, OAuth
   **/
  override global List<DataSource.AuthenticationCapability> getAuthenticationCapabilities() {
    List<DataSource.AuthenticationCapability> capabilities =
        new List<DataSource.AuthenticationCapability>();
    capabilities.add(DataSource.AuthenticationCapability.ANONYMOUS);

    return capabilities;
  }

  /**
   * @description Declare the functional capabilities that the external system supports.
   *     Other capabilities: create, update, delete.
   **/
  override global List<DataSource.Capability> getCapabilities() {
    List<DataSource.Capability> capabilities = new
        List<DataSource.Capability>();
    capabilities.add(DataSource.Capability.ROW_QUERY);
    capabilities.add(DataSource.Capability.SEARCH);
    capabilities.add(DataSource.Capability.QUERY_PAGINATION_SERVER_DRIVEN);

    return capabilities;
  }

  /**
   * @description Declare the associated DataSource.Connection class.
   **/
  override global DataSource.Connection getConnection(
      DataSource.ConnectionParams connectionParams) {
    return new BuganizerDataSourceConnection(connectionParams);
  }
}