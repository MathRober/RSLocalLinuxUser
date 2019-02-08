$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$here = Split-Path -Parent $here
$RutaModulo = "$here\Modules\RSLocalLinuxUser"
$Modulo = "RSLocalLinuxUser"

Get-Module $Modulo | Remove-Module -Force

Import-Module $here\Modules\RSLocalLinuxUser\RSLocalLinuxUser.psd1

Describe 'Tests Unitarios de Get-LocalLinuxUser'{
    Mock -CommandName Get-Content -Verifiable -MockWith {
        [object[]]('root:x:0:0:root:/root:/bin/bash',
                 'usuario1:x:1001:1005::/home/usuario1:/bin/sh'
                 )
    } -ModuleName $Modulo
    Mock -CommandName Test-Path -Verifiable -MockWith {return $true} -ModuleName $Modulo
    Context 'Obtener todos los usuarios' {
        $resultado = Get-LocalLinuxUser -System $true
        It "Debe devolver dos objetos" {
            $resultado.Count | Should -Be 2
        }
        It 'Debe devolver los valores adecuados'{
            $resultado[0].Username | Should -Be 'root'
            $resultado[0].Username | Should -BeOfType [string]
            $resultado[0].UserID   | Should -Be 0
            $resultado[0].UserID   | Should -BeOfType [int]
        }
        It 'La función Test-Path se llama una vez.'{
            Assert-MockCalled Test-Path -Exactly 1 -ModuleName $Modulo
        }
        It 'La función Get-Content se llama una vez.'{
            Assert-MockCalled Get-Content -Exactly 1 -ModuleName $Modulo
        }
    }
    Context 'Obtener solo usuarios que no sean de sistema' {
        $resultado = @()
        $resultado += Get-LocalLinuxUser 
        It "Debe devolver un objeto" {
            $resultado.Count | Should -Be 1
        }
        It 'Debe devolver los valores adecuados'{
            $resultado[0].Username | Should -Be 'usuario1'
            $resultado[0].Username | Should -BeOfType [string]
            $resultado[0].UserID   | Should -Be 1001
            $resultado[0].UserID   | Should -BeOfType [int]
        }
        It 'La función Test-Path se llama una vez.'{
            Assert-MockCalled Test-Path -Exactly 1 -ModuleName $Modulo
        }
        It 'La función Get-Content se llama una vez.'{
            Assert-MockCalled Get-Content -Exactly 1 -ModuleName $Modulo
        }
    }
    Context 'El archivo /etc/passwd no existe'{
        Mock -CommandName Test-Path -Verifiable -MockWith {return $false} -ModuleName $Modulo 
        It 'El archivo /etc/passwd no existe'{
            $F_error = {Get-LocalLinuxUser} | Should -Throw -PassThru
            $F_error.Exception.Message | Should -Be "The file /etc/passwd doesn't exist"
        }  
        It 'La función Test-Path se llama una vez.'{
            Assert-MockCalled Test-Path -Exactly 1 -ModuleName $Modulo
        }
        It 'La función Get-Content no se llama.'{
            Assert-MockCalled Get-Content -Exactly 0 -ModuleName $Modulo
        }    
    }
   
}
Remove-Module RSLocalLinuxUser
