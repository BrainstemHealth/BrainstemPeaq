# SilencioPeaq
Silencio Peaq Implementian



# Brainstem additions for the peaq get real campaign

## Tasks to be done for get real and how they were done 

The whole protocol/way of participating in the getreal campaign is explained in this document: https://docs.google.com/document/d/1aguWiMBhP6VNOjVGJgYS1OfTaD2se2QZeKVnFcQOMNo/edit?tab=t.0#heading=h.fp8i95knx87r

With this current implementation the completion of this process is possible.

There are specific elements in here that are important to highlight:
1. Which network to use, which RPC etc.
2. Transaction fee management - this has not been solved so far
3. Connecting the user's email to the peaq ID -> in this solution this is hard coded in the Example ViewController, the remainder of the process is implemented in the Example ViewController and peaq.swift in the peaq-iOS library.
4. Tracking user data generation -> in this solution this is hard coded in the Example ViewController, the remainder of the process is implemented in the Example ViewController and peaq.swift in the peaq-iOS library.
5. The testing part is done via the same email used in the code and the peaq test Galxe space that is defined in the document: https://app.galxe.com/quest/peaq/GCpEitg8Ms

The API keys and Task etc. will all change before this goes live. So far we did not hear from them about this.

## How is the code structured?

There is a framework to handle the peaq interactions in peaq-iOS code, specifically peaq.swift.
The new part that was added here (compared to the previous peaq functions) is:
- createEmaiSignature this function uses the API keys and the emails to achieve 3. in the list above 
- registerTaskCompletion this function uses the API keys and achieves 4. in the list above

The user data is simulated in the Example app in the ViewController and the buttons are connected there to enable the process.

First a peaq lift off id has to be created, then the email has to be registered, then task data has to be submitted, after that there needs to be a data storage transaction.

It is important that a itemType cannot be reused. That is why there is a random new one generated if the user goes through the process. But it has to be reused for the steps, so it is stored in a global variable lastStoredItemType.

There is a wallet for the user, there is a wallet for the device, these are not really very well stored or handled in this version. In a real app this has to be improved.

For each project there will be multiple tasks where the user contributes.


