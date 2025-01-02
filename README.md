# AWS Cleanup (Docker Image)  

Automated rules-based cleanup of AWS resources.

## Functionality

This image is currently a work in progress.  It is currently capable of:

### Current Functionality

- [x] Shutdown EC2 instances for disabled accounts
- [x] Shutdown EC2 instances based on workdays and workhours
- [x] Save inventory of resources to disk

### Planned Functionality

- [ ] Alerting account owner on activity via email and priority
- [ ] Cleaning resources based on naming conventions
- [ ] Cleaning resources based on tags
- [ ] Cleaning resources based on resource policies
- [ ] Cleaning resources based on resource types

## Running the Container

```bash
docker run --rm \
  -v ./path/to/config:/var/aws-cleanup/config \
  -v ./path/to/output:/var/aws-cleanup/output \
  fredlackey/aws-cleanup:latest
```

## Example Output

```bash
Account: CVLE Dev JBlow (111111111111)
  Using GovCloud regions
  Checking region: us-gov-east-1
  Successfully retrieved instances from us-gov-east-1
  Processing instances:
    No instances found
  Shutting down instances due to schedule/disabled status...
    No running instances found
  Checking region: us-gov-west-1
  Successfully retrieved instances from us-gov-west-1
  Processing instances:
    - i-0adc47cdf203ba699 (Win 11 Workstation) - running
    - i-08894fe99d94d8586 (linux-server-2) - running
    - i-09cc7ea8b94b6fe22 (windows-server-1) - running
    - i-0f037c4b18de72b22 (linux-server-1) - stopped
    - i-03f00a917c1134cce (linux-lamp) - stopped
    - i-06aa3d0cc51fb2da1 (linux-lamp-2) - stopped
  Shutting down instances due to schedule/disabled status...
    - i-0adc47cdf203ba699 (Win 11 Workstation)
    - i-08894fe99d94d8586 (linux-server-2)
    - i-09cc7ea8b94b6fe22 (windows-server-1)
```

## Configuration  

Create a local `config` folder.  Within that folder, create an `accounts.json` file containing an array of your AWS accounts as well as admin-level credentials for the account.  

```json
[
  {
    "id": "11111111111111",
    "name": "Sandobx Environment",
    "access": "AWS_ACCESS_KEY_ID",
    "secret": "AWS_SECRET_ACCESS_KEY",
    "govcloud": true,
    "workdays": "M,T,W,Th,F",
    "workhours": "0900-1600"
  },
  {
    "id": "22222222222222",
    "name": "Dev Environment",
    "access": "AWS_ACCESS_KEY_ID",
    "secret": "AWS_SECRET_ACCESS_KEY",
    "govcloud": true,
    "workdays": "M,T,W,Th,F"
  },
  {
    "id": "33333333333333",
    "name": "Production Environment",
    "access": "AWS_ACCESS_KEY_ID",
    "secret": "AWS_SECRET_ACCESS_KEY",
    "govcloud": true
  },
  {
    "id": "44444444444444",
    "name": "Management Account",
    "access": "AWS_ACCESS_KEY_ID",
    "secret": "AWS_SECRET_ACCESS_KEY"
  }
]
```  

### Parameters

#### `id` : Account ID (required)

The AWS account ID.  Used to confirm security credentials are correct.  Upon connection the account ID is verified.  If the account ID is not verified, the account is skipped.

#### `name` : Account Name (required)

The name of the account displayed in the output.

#### `access` & `secret` : AWS Access Key ID & Secret (required)

The AWS access key ID and secret access key for the account.  These are used to authenticate the account with AWS.

#### `govcloud` : Whether the account is in GovCloud (optional)

Whether the account is in GovCloud.  If true, the account is assumed to be in GovCloud and the regions are filtered to only include GovCloud regions.

#### `workdays` & `workhours` : Workdays & Workhours (optional)

If one or both of these parameters are provided, the instances are shutdown outside of the workdays and workhours.  If only `workdays` is provided, the instances are shutdown outside of the workdays.  If only `workhours` is provided, the instances are shutdown outside of the workhours.  If both `workdays` and `workhours` are provided, the instances are shutdown outside of the workdays and workhours.  

### Contact Information

If you have any questions or feedback, please contact me.

**Fred Lackey**  
**[fred.lackey@gmail.com](mailto:fred.lackey@gmail.com)**  
**[fredlackey.com](https://fredlackey.com)**  
**[linkedin.com/in/fredlackey](https://linkedin.com/in/fredlackey)**
