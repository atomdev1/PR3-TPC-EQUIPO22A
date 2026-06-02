using Dominio.Enums;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Dominio
{
    public class Usuario
    {
        public int IdUsuario { get; set; }
        public string DNI { get; set; }
        public string Nombre { get; set; }
        public string Apellido { get; set; }
        public string Telefono { get; set; }
        public string Email { get; set; }
        public string PasswordHash { get; set; }
        public DateTime FechaNacimiento { get; set; } 
        public DateTime FechaRegistro { get; set; }  
        public bool Activo { get; set; } // Baja lógica del usuario
        public int CantidadAsistencias { get; set; }
        public RolUsuario Rol { get; set; } // Uso del Enum para control de perfiles
    }
}
