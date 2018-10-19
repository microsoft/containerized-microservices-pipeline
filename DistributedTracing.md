# Distributed Tracing

A distributed tracing solution is expected to correlate telemetry emitted by each microservice that participates in serving a request.

## Concepts

### Correlation

To enable proper correlation all telemetry should contain the following attributes

- Correlation Id - Uniquely identifies an instance of a single request. This is typically initiated and assigned in reaction to user action.
- Operation Id - Uniquely identifies an operation of a single microservice executed in the request chain.
- Parent Operation Id - The operation that proceeded and initiated the current operation.

#### Key Telemetry Attributes

##### Correlation Id

The correlation id represents an instance of a request, end to end. This identifier would be used to find all telemetry recorded for the request. Typically this identifier would be provided to each service participating in the request execution so that the telemetry that service records includes this identifier.

##### Operation and Parent Operation Id

The operation id represents a single unit of work performed during a request execution. In a microservices architecture multiple services will likely participate in the request execution. The operation id would typically represent the work performed by each participating service. The Parent Operation Id would be added to the telemetry to indicate which operation triggered the current operation to execute.

By embedding this hierarchy in the telemetry, this allows for representing the flow of request execution from one service to another. This allows for discovering run-time dependencies between services. More importantly, this will make it simple to see between what services did a request is slow or failing.

#### Conceptual Example

_// TODO: Add an image that illustrates capturing correlation and hierarchy between services participating in request execution_

### Service-to-Service Latency

This would measure the amount of time occupied by transferring the execution of a request from one service to another. Its important to measure the amount of time it takes for the network to transfer these requests to ensure response time is not increasing as a result of an overwhelmed network or poor serialization/deserialization performance.

#### Calculating Latency

Service A calls Service B. Service B took 20ms to complete its operation. However, from Service A, Service B took 30ms to complete its operation. The difference between the Service B's duration from Service B's internal perspective and Service A's perspective is the latency incurred. Since this is a round trip, the latency should be divided in half. In this example the latency metric should be recorded for 5ms latency ((30-20)/2).

### Telemetry End Times for Asynchronous Operations

Ahead of implementing any distributed tracing, there needs to be a conscious decision about whether or not end times for parent operations reflect the end times of asynchronous child operations. In long running workflow or map-reduce operations it will be important for the end times of parent operations to reflect their asynchronous child operations end time so that the total time to complete the workflow can be easily determined and analyzed. If the asynchronous operation taking place in a third-party system or outside the domain/scope of the current application, end times of parent operations likely do not need to reflect the end times of the child asynchronous operations due to lack of responsibility for those child operations.

#### Examples

When multiple services are participating in request execution, the end times should reflect dependent calls to other services. For example, given a serial call chain service A > service B > service C, service B's end time should be greater than service C's end time. Additionally, service A's end time should be greater than B and C's end time. This representation will happen naturally when remote call execution is synchronous. However, this will not happen naturally when the remote call execution is asynchronous. 

_// TODO: Add figure to illustrate serial, synchronous, request execution

Lets say that between service B and C, there exists a message queue. Service B publishes the message to the message queue and service C consumes the message. Service B would respond immediately after the message queue acknowledges receipt of the message. Therefore, service B's end time would be less than service C's end time.

_// TODO: Add figure to illustrate serial, asynchronous, request execution

Lets take this example one step further and introduce service D. Service B publishes now two messages to different message queues. Service C and Service D each subscribe to one of the queues resulting in asynchronous and parallel operations participating in the request execution. Similarly to the previous example, service b's end time will be less than that of service c and d. However, in this example, it becomes much more difficult to determine how long the request took; including the asynchronous operations.

_// TODO: Add figure to illustrate parallel, asynchronous, request execution