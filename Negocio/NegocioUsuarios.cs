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

        // Clientes activos para el combo del alta de reserva.
        public List<Usuario> ObtenerClientes()
        {
            List<Usuario> lista = new List<Usuario>();
            AccesoDatos datos = new AccesoDatos();
            try
            {
                datos.SetearConsulta(@"
                    SELECT IDUsuario, DNI, Nombre, Apellido
                    FROM Usuarios
                    WHERE Activo = 1 AND IDRol = @rolCliente
                    ORDER BY Apellido, Nombre");
                datos.AgregarParametro("@rolCliente", (int)RolUsuario.Cliente);
                datos.EjecutarLectura();
                while (datos.Lector.Read())
                {
                    lista.Add(new Usuario
                    {
                        IdUsuario = (int)datos.Lector["IDUsuario"],
                        DNI = (string)datos.Lector["DNI"],
                        Nombre = (string)datos.Lector["Nombre"],
                        Apellido = (string)datos.Lector["Apellido"]
                    });
                }
                return lista;
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

        public Usuario VerificarIdentidad(string dni, string email, DateTime fechaNacimiento)
        {
            AccesoDatos datos = new AccesoDatos();
            try
            {
                datos.SetearConsulta(@"
                    SELECT IDUsuario, DNI, Nombre, Apellido, Telefono, Email,
                           FechaNacimiento, FechaRegistro, Activo, CantidadAsistencias, IDRol
                    FROM Usuarios
                    WHERE DNI = @dni AND Email = @email
                          AND CONVERT(date, FechaNacimiento) = CONVERT(date, @fechaNacimiento)
                          AND Activo = 1");
                datos.AgregarParametro("@dni", dni);
                datos.AgregarParametro("@email", email);
                datos.AgregarParametro("@fechaNacimiento", fechaNacimiento);
                datos.EjecutarLectura();

                if (datos.Lector.Read())
                {
                    return new Usuario
                    {
                        IdUsuario = (int)datos.Lector["IDUsuario"],
                        DNI = (string)datos.Lector["DNI"],
                        Nombre = (string)datos.Lector["Nombre"],
                        Apellido = (string)datos.Lector["Apellido"],
                        Telefono = datos.Lector["Telefono"] is DBNull ? "" : (string)datos.Lector["Telefono"],
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

        public void ActualizarPassword(int idUsuario, string nuevaPassword)
        {
            AccesoDatos datos = new AccesoDatos();
            try
            {
                datos.SetearConsulta("UPDATE Usuarios SET Password = @password WHERE IDUsuario = @id");
                datos.AgregarParametro("@password", ComputarSHA256(nuevaPassword));
                datos.AgregarParametro("@id", idUsuario);
                datos.EjecutarAccion();
            }
            finally
            {
                datos.CerrarConexion();
            }
        }
    }
}
