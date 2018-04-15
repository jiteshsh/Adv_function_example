# $JSErrorLogPreference = 'c:\errors.txt'
function get-JSSysteminfo { 
        
        [CMDLetBinding()]                 #---- Makes simple parametrize function into an Advance function or you can call it Script CommandLets = That enables number of new feature#   
        param(
        [Parameter(Mandatory=$true,                       #---- Mandatory was enabled via adding CMDLetBinding()#
                   ValueFromPipeLine=$true,               #---- Enabling this function to accept computer name via value #
                   ValueFromPipeLineByPropertyName=$true, #---- Enabling this function to accept computer name via pipeline #
                   ParameterSetName='Name',       #---- Creating parameterset,  which are basically different SETS of valid parameters or you can say we will have 2 different syntax
                   HelpMessage="Please enter the ComputerName or the Ipaddress to query WMI")]
                     
        [Alias('hostname')]                               # ---- Addding Alias, we can then use hostname instead of computer as a paramter# 
        [ValidateLength(1,10)]                            # ---- Addding Validationlenght, the ComputerName should have minimum 4 char and maximum 10 char # 
        [string[]]$ComputerName,                          # ---- Adding [], will allow multiple values---#


        [Parameter(Mandatory=$true,
                  ParameterSetName='Ip',
                  HelpMessage='Ipaddress to query WMI' )]
        [ValidatePattern('\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}')]    #----- Regx for Ipaddress---#
        [String[]]$ipaddress,
        
        [Parameter()]   # We are not making ErrorLogFilePath mandatory#
        [string]$ErrorLogFilePath = $JSErrorLogPreference
        )

        BEGIN{
                    <# --- Why we wrote the below code : the process section contains $computername. What if user type ipaddress. 
                    Thus we are using inbuilt variable called PSBoundParameters to catch if user select Ipaddress & then move the value of Ipaddress to computername #> 
            if($PSBoundParameters.ContainsKey('ipaddress')){
               
               $ComputerName = $ipaddress
            }        
        }        
        PROCESS{  
            Foreach ($Computer in $ComputerName) {   
             
                $os = Get-WmiObject -Class win32_operatingsystem -ComputerName $Computer 
                $cs = Get-WmiObject -Class win32_computersystem -ComputerName $Computer 
                
                #----Here I am creating a Hashtable, which has value from both the command--------#
                $Props = @{'ComputerName'=$Computer;
                           'OSVersion'=$os.version; 
                           'OSBuild'=$os.buildnumber;
                           'Model'=$cs.model;
                           'RAM'=$cs.totalphysicalmemory /1GB -as [int];
                           'SystemType' = $cs.SystemType
                           } 

                #------Here I am creating a object and property of the obect would be the values we have in the Hashtable-------#
                $newobject = New-Object -TypeName psobject -Property $Props

                Write-Output $newobject | ft -Property ComputerName, RAM, OSBuild, Model, OSVersion
               
           }
       }
       END{}
}
