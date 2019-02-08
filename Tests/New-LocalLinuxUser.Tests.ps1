
$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$here = Split-Path -Parent $here
$RutaModulo = "$here\Modules\RSLocalLinuxUser"
$Modulo = "RSLocalLinuxUser"

Get-Module $Modulo | Remove-Module -Force

Import-Module $here\Modules\RSLocalLinuxUser\RSLocalLinuxUser.psd1

function Start-Process {}

Describe 'Tests Unitarios de New-LocalLinuxUser'{
    Context 'Creación correcta de un usuario' {
        Mock -CommandName Start-Process -Verifiable -MockWith {return $null} -ModuleName $Modulo

        It "Debe devolver la cadena correcta." {
            $resultado = New-LocalLinuxUser -Name 'usuario1' -Password ('aa' | ConvertTo-SecureString -AsPlainText -Force) -Account '2020-01-01'
            $resultado | Should -Be "Usuario creado correctamente."
        }
        It 'La función Start-Process se llama dos veces.'{
            Assert-MockCalled Start-Process -Exactly 2 -ModuleName $Modulo
        }
    }
   
}
Remove-Module RSLocalLinuxUser
