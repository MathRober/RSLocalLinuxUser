$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$here = Split-Path -Parent $here
$RutaModulo = "$here\Modules\RSLocalLinuxUser"

$Modulo = 'RSLocalLinuxUser'

Get-Module $Modulo | Remove-Module -Force
#$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.ps1', '.psm1'
#import-Module  "$here\Modules\RSLocalLinuxUser\Izfe$sut"

Describe "Pruebas unitarias sobre el módulo $Modulo"{

  Context 'Configuración del módulo' {  
    It 'Existe el archivo de manifiesto'{
        "$RutaModulo\$Modulo.psd1" | Should Exist
    }
    It 'El manifiesto incluye al módulo' {
         (Import-PowerShellDataFile -Path "$RutaModulo\$Modulo.psd1").RootModule | Should Contain "$Modulo.psm1"
    }
    It 'Existe el archivo .psm1'{
        "$RutaModulo\$Modulo.psm1" | Should Exist
    }
    It "Modulo contiene código válido"{
        $Contenido = Get-Content -Path "$RutaModulo\$Modulo.psm1" -ErrorAction Stop
        $errores = $null
        $null = [System.Management.Automation.PSParser]::Tokenize($Contenido, [ref]$errores)
        $errores.Count | Should be 0

    }
   }


    $funciones = (  "New-LocalLinuxUser",
                    "Get-LocalLinuxUser",
                    "Remove-LocalLinuxUser",
                    "Reset-LocalLinuxUserPassword"
    )
    Import-Module $RutaModulo\$Modulo.psm1 -force
    Context "Comprobación de funciones" {
        foreach($funcion in $funciones)
        {
                It "Existe la función $funcion en el módulo" {
                    (Get-Command $funcion -Module $Modulo).Name | Should Be $funcion
                }
                It 'Tiene que ser una función avanzada' {
                    (Get-command $funcion -Module $Modulo).Definition | Should Match '[CmdletBinding()]'
                }
                It "Existe un test para la función $funcion" {
                    "$here\Tests\$funcion.Tests.ps1" | Should Exist
                }
          
        }
   }
}