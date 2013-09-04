 public interface Test
 {
     public String[] queue();

     public String jobStatus( int jobid );
     public String jobOutput( int jobid );

     public String test();

     public String createFileEntry( String name, String description, int channels, int samples, String format, String precision );

     public int infomax( int fileid, String sphering, float annealing, 
        float annealingDegree, int blockSize, float learningRate, 
        int maxSteps, float stopCondition, int seed );

     public int fastIca( int fileid, String sphering, String initialization,
        String contrastFunction, int maxIterations,
        int maximumRetries, float convergenceTolerance );

     public int sobi( int fileid, String sphering );

 }

