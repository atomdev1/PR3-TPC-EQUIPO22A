using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Dominio;
using Dominio.Enums;
using System.Security.Cryptography;


namespace Negocio
{
    public class NegocioUsuarios
    {
        public Usuario Login(string email, string password)
        {
            AccesoDatos datos = new AccesoDatos();
            try
            {
                datos.SetearConsulta(@"
                    SELECT IDUsuario, DNI, Nombre, Apellido, Telefono, Email,
                           FechaNacimiento, FechaRegistro, Activo, CantidadAsistencias, IDRol
                    FROM Usuarios
                    WHERE Email = @email AND Password = @password AND Activo = 1");
                datos.AgregarParametro("@email", email);
                datos.AgregarParametro("@password", ComputarSHA256(password));
                datos.EjecutarLectura();

                if (datos.Lector.Read())
                {
                    return new Usuario
                    {
                        IdUsuario = (int)datos.Lector["IDUsuario"],
                        DNI = (string)datos.Lector["DNI"],
                        Nombre = (string)datos.Lector["Nombre"],
                        Apellido = (string)datos.Lector["Apellido"],
                        Telefono = (string)datos.Lector["Telefono"],
                        Email = (string)datos.Lector["Email"],
                        FechaNacimiento = (DateTime)datos.Lector["FechaNacimiento"],
                        FechaRegistro = (DateTime)datos.Lector["FechaRegistro"],
                        Activo = (bool)datos.Lector["Activo"],
                        CantidadAsistencias = (int)datos.Lector["CantidadAsistencias"],
                        Rol = (RolUsuario)(int)datos.Lector["IDRol"]
                    };
                }
                return null;
            }
            finally
            {
                datos.CerrarConexion();
            }
        }

        private static string ComputarSHA256(string texto)
        {
            using (SHA256 sha = SHA256.Create())
            {
                byte[] bytes = sha.ComputeHash(Encoding.UTF8.GetBytes(texto));
                return BitConverter.ToString(bytes).Replace("-", "").ToLower();
            }
        }
    }
}
