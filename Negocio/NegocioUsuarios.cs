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

        // Todos los usuarios (activos e inactivos) para la grilla del ABM: la baja es lógica, hay que poder reactivar.
        public List<Usuario> ObtenerTodos()
        {
            List<Usuario> lista = new List<Usuario>();
            AccesoDatos datos = new AccesoDatos();
            try
            {
                datos.SetearConsulta(@"
                    SELECT IDUsuario, DNI, Nombre, Apellido, Telefono, Email,
                           FechaNacimiento, FechaRegistro, Activo, CantidadAsistencias, IDRol
                    FROM Usuarios
                    ORDER BY Apellido, Nombre");
                datos.EjecutarLectura();
                while (datos.Lector.Read())
                {
                    lista.Add(MapearUsuario(datos));
                }
                return lista;
            }
            finally
            {
                datos.CerrarConexion();
            }
        }

        // Un usuario por Id, para editar en el ABM y para la pantalla de Perfil.
        public Usuario ObtenerPorId(int idUsuario)
        {
            AccesoDatos datos = new AccesoDatos();
            try
            {
                datos.SetearConsulta(@"
                    SELECT IDUsuario, DNI, Nombre, Apellido, Telefono, Email,
                           FechaNacimiento, FechaRegistro, Activo, CantidadAsistencias, IDRol
                    FROM Usuarios
                    WHERE IDUsuario = @id");
                datos.AgregarParametro("@id", idUsuario);
                datos.EjecutarLectura();
                if (datos.Lector.Read())
                {
                    return MapearUsuario(datos);
                }
                return null;
            }
            finally
            {
                datos.CerrarConexion();
            }
        }

        // Alta de usuario. La usa el ABM (rol elegido por el admin) y Registrarse (rol Cliente).
        // El choque de UNIQUE en DNI/Email vuelve como SqlException y lo captura la pagina.
        // FechaRegistro, Activo y CantidadAsistencias los resuelve el DEFAULT de la tabla.
        public void Agregar(Usuario u, string password)
        {
            AccesoDatos datos = new AccesoDatos();
            try
            {
                datos.SetearConsulta(@"
                    INSERT INTO Usuarios (DNI, Nombre, Apellido, Telefono, Email, Password, FechaNacimiento, IDRol)
                    VALUES (@dni, @nombre, @apellido, @telefono, @email, @password, @fechaNacimiento, @idRol)");
                datos.AgregarParametro("@dni", u.DNI);
                datos.AgregarParametro("@nombre", u.Nombre);
                datos.AgregarParametro("@apellido", u.Apellido);
                datos.AgregarParametro("@telefono", string.IsNullOrEmpty(u.Telefono) ? "" : u.Telefono);
                datos.AgregarParametro("@email", u.Email);
                datos.AgregarParametro("@password", ComputarSHA256(password));
                datos.AgregarParametro("@fechaNacimiento", u.FechaNacimiento);
                datos.AgregarParametro("@idRol", (int)u.Rol);
                datos.EjecutarAccion();
            }
            finally
            {
                datos.CerrarConexion();
            }
        }

        // Edición de datos y rol. No toca el DNI ni el Password
        // (la contraseña se cambia por su flujo propio ActualizarPassword).
        public void Modificar(Usuario u)
        {
            AccesoDatos datos = new AccesoDatos();
            try
            {
                datos.SetearConsulta(@"
                    UPDATE Usuarios SET
                        Nombre          = @nombre,
                        Apellido        = @apellido,
                        Telefono        = @telefono,
                        Email           = @email,
                        FechaNacimiento = @fechaNacimiento,
                        IDRol           = @idRol
                    WHERE IDUsuario = @id");
                datos.AgregarParametro("@nombre", u.Nombre);
                datos.AgregarParametro("@apellido", u.Apellido);
                datos.AgregarParametro("@telefono", string.IsNullOrEmpty(u.Telefono) ? "" : u.Telefono);
                datos.AgregarParametro("@email", u.Email);
                datos.AgregarParametro("@fechaNacimiento", u.FechaNacimiento);
                datos.AgregarParametro("@idRol", (int)u.Rol);
                datos.AgregarParametro("@id", u.IdUsuario);
                datos.EjecutarAccion();
            }
            finally
            {
                datos.CerrarConexion();
            }
        }

        // Baja lógica: no se borra el registro, se apaga el flag Activo.
        public void BajaLogica(int idUsuario)
        {
            AccesoDatos datos = new AccesoDatos();
            try
            {
                datos.SetearConsulta("UPDATE Usuarios SET Activo = 0 WHERE IDUsuario = @id");
                datos.AgregarParametro("@id", idUsuario);
                datos.EjecutarAccion();
            }
            finally
            {
                datos.CerrarConexion();
            }
        }

        public void Reactivar(int idUsuario)
        {
            AccesoDatos datos = new AccesoDatos();
            try
            {
                datos.SetearConsulta("UPDATE Usuarios SET Activo = 1 WHERE IDUsuario = @id");
                datos.AgregarParametro("@id", idUsuario);
                datos.EjecutarAccion();
            }
            finally
            {
                datos.CerrarConexion();
            }
        }

        // Arma un Usuario a partir del lector. Telefono y FechaNacimiento pueden venir NULL de la
        // tabla, por eso se leen contra DBNull para que la grilla del ABM no falle con datos incompletos.
        private static Usuario MapearUsuario(AccesoDatos datos)
        {
            return new Usuario
            {
                IdUsuario           = (int)datos.Lector["IDUsuario"],
                DNI                 = (string)datos.Lector["DNI"],
                Nombre              = (string)datos.Lector["Nombre"],
                Apellido            = (string)datos.Lector["Apellido"],
                Telefono            = datos.Lector["Telefono"] is DBNull ? "" : (string)datos.Lector["Telefono"],
                Email               = (string)datos.Lector["Email"],
                FechaNacimiento     = datos.Lector["FechaNacimiento"] is DBNull ? DateTime.MinValue : (DateTime)datos.Lector["FechaNacimiento"],
                FechaRegistro       = (DateTime)datos.Lector["FechaRegistro"],
                Activo              = (bool)datos.Lector["Activo"],
                CantidadAsistencias = (int)datos.Lector["CantidadAsistencias"],
                Rol                 = (RolUsuario)(int)datos.Lector["IDRol"]
            };
        }
    }
}
