public class AsyncExecution implements Queueable {
    public void execute(QueueableContext context) {
        V3CatalogTransformation instance = new V3CatalogTransformation();
        instance.productsTransformation();    
    }
}