using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Dominio;
using Dominio.Enums;


namespace Negocio
{
    public class NegocioCupones
    {
        public List<Cupon> ObtenerTodas()
        {
            List<Cupon> lista = new List<Cupon>();
            AccesoDatos datos = new AccesoDatos();

            try
            {
                datos.SetearConsulta(@"
                    SELECT c.IDCupon, c.Codigo, c.Descripcion, c.IDEstadoCupon,
                           c.IDTipoDescuento, c.ValorDescuento, c.ReservasRequeridas,
                           c.ValidoDesde, c.ValidoHasta, c.LimiteUsos, c.UsosActuales,
                           c.IDUsuario, u.Nombre, u.Apellido
                    FROM Cupones c
                    INNER JOIN Usuarios u ON u.IDUsuario = c.IDUsuario
                    WHERE c.IDEstadoCupon <> 5");
                datos.EjecutarLectura();

                while (datos.Lector.Read())
                {
                    Cupon c = new Cupon();
                    c.IdCupon = (int)datos.Lector["IDCupon"];
                    c.Codigo = (string)datos.Lector["Codigo"];
                    c.Descripcion = (string)datos.Lector["Descripcion"];
                    c.Estado = (EstadoCupon)(int)datos.Lector["IDEstadoCupon"];
                    c.TipoDescuento = (TipoDescuento)(int)datos.Lector["IDTipoDescuento"];
                    c.ValorDescuento = datos.Lector["ValorDescuento"] is DBNull ? (decimal?)null : (decimal)datos.Lector["ValorDescuento"];
                    c.ReservasRequeridas = (int)datos.Lector["ReservasRequeridas"];
                    c.ValidoDesde = datos.Lector["ValidoDesde"] is DBNull ? (DateTime?)null : (DateTime)datos.Lector["ValidoDesde"];
                    c.ValidoHasta = datos.Lector["ValidoHasta"] is DBNull ? (DateTime?)null : (DateTime)datos.Lector["ValidoHasta"];
                    c.LimiteUsos = datos.Lector["LimiteUsos"] is DBNull ? (int?)null : (int)datos.Lector["LimiteUsos"];
                    c.UsosActuales = (int)datos.Lector["UsosActuales"];
                    c.Usuario = new Usuario
                    {
                        IdUsuario = (int)datos.Lector["IDUsuario"],
                        Nombre = (string)datos.Lector["Nombre"],
                        Apellido = (string)datos.Lector["Apellido"]
                    };
                    lista.Add(c);
                }
                return lista;
            }
            catch (Exception)
            {
                throw;
            }
            finally
            {
                datos.CerrarConexion();
            }
        }

        // Cupones de un cliente puntual: todos menos los anulados (estado 5).
        // La vista cliente separa Activos (usables) del resto (historial) en memoria.
        public List<Cupon> ObtenerPorUsuario(int idUsuario)
        {
            List<Cupon> lista = new List<Cupon>();
            AccesoDatos datos = new AccesoDatos();

            try
            {
                datos.SetearConsulta(@"
                    SELECT c.IDCupon, c.Codigo, c.Descripcion, c.IDEstadoCupon,
                           c.IDTipoDescuento, c.ValorDescuento, c.ReservasRequeridas,
                           c.ValidoDesde, c.ValidoHasta, c.LimiteUsos, c.UsosActuales,
                           c.IDUsuario, u.Nombre, u.Apellido
                    FROM Cupones c
                    INNER JOIN Usuarios u ON u.IDUsuario = c.IDUsuario
                    WHERE c.IDUsuario = @id AND c.IDEstadoCupon <> 5
                    ORDER BY c.IDEstadoCupon, c.ValidoHasta");
                datos.AgregarParametro("@id", idUsuario);
                datos.EjecutarLectura();

                while (datos.Lector.Read())
                {
                    Cupon c = new Cupon();
                    c.IdCupon = (int)datos.Lector["IDCupon"];
                    c.Codigo = (string)datos.Lector["Codigo"];
                    c.Descripcion = (string)datos.Lector["Descripcion"];
                    c.Estado = (EstadoCupon)(int)datos.Lector["IDEstadoCupon"];
                    c.TipoDescuento = (TipoDescuento)(int)datos.Lector["IDTipoDescuento"];
                    c.ValorDescuento = datos.Lector["ValorDescuento"] is DBNull ? (decimal?)null : (decimal)datos.Lector["ValorDescuento"];
                    c.ReservasRequeridas = (int)datos.Lector["ReservasRequeridas"];
                    c.ValidoDesde = datos.Lector["ValidoDesde"] is DBNull ? (DateTime?)null : (DateTime)datos.Lector["ValidoDesde"];
                    c.ValidoHasta = datos.Lector["ValidoHasta"] is DBNull ? (DateTime?)null : (DateTime)datos.Lector["ValidoHasta"];
                    c.LimiteUsos = datos.Lector["LimiteUsos"] is DBNull ? (int?)null : (int)datos.Lector["LimiteUsos"];
                    c.UsosActuales = (int)datos.Lector["UsosActuales"];
                    c.Usuario = new Usuario
                    {
                        IdUsuario = (int)datos.Lector["IDUsuario"],
                        Nombre = (string)datos.Lector["Nombre"],
                        Apellido = (string)datos.Lector["Apellido"]
                    };
                    lista.Add(c);
                }
                return lista;
            }
            catch (Exception)
            {
                throw;
            }
            finally
            {
                datos.CerrarConexion();
            }
        }

        public List<Usuario> ObtenerUsuarios()
        {
            List<Usuario> lista = new List<Usuario>();
            AccesoDatos datos = new AccesoDatos();

            try
            {
                datos.SetearConsulta("SELECT IDUsuario, Nombre, Apellido FROM Usuarios WHERE Activo = 1");
                datos.EjecutarLectura();

                while (datos.Lector.Read())
                {
                    lista.Add(new Usuario
                    {
                        IdUsuario = (int)datos.Lector["IDUsuario"],
                        Nombre = (string)datos.Lector["Nombre"],
                        Apellido = (string)datos.Lector["Apellido"]
                    });
                }
                return lista;
            }
            catch (Exception)
            {
                throw;
            }
            finally
            {
                datos.CerrarConexion();
            }
        }

        public Cupon ObtenerPorId(int idCupon)
        {
            AccesoDatos datos = new AccesoDatos();

            try
            {
                datos.SetearConsulta(@"
                    SELECT IDCupon, Codigo, Descripcion, IDEstadoCupon,
                           IDTipoDescuento, ValorDescuento, ReservasRequeridas,
                           ValidoDesde, ValidoHasta, LimiteUsos, UsosActuales, IDUsuario
                    FROM Cupones
                    WHERE IDCupon = @id");
                datos.AgregarParametro("@id", idCupon);
                datos.EjecutarLectura();

                if (datos.Lector.Read())
                {
                    Cupon c = new Cupon();
                    c.IdCupon = (int)datos.Lector["IDCupon"];
                    c.Codigo = (string)datos.Lector["Codigo"];
                    c.Descripcion = (string)datos.Lector["Descripcion"];
                    c.Estado = (EstadoCupon)(int)datos.Lector["IDEstadoCupon"];
                    c.TipoDescuento = (TipoDescuento)(int)datos.Lector["IDTipoDescuento"];
                    c.ValorDescuento = datos.Lector["ValorDescuento"] is DBNull ? (decimal?)null : (decimal)datos.Lector["ValorDescuento"];
                    c.ReservasRequeridas = (int)datos.Lector["ReservasRequeridas"];
                    c.ValidoDesde = datos.Lector["ValidoDesde"] is DBNull ? (DateTime?)null : (DateTime)datos.Lector["ValidoDesde"];
                    c.ValidoHasta = datos.Lector["ValidoHasta"] is DBNull ? (DateTime?)null : (DateTime)datos.Lector["ValidoHasta"];
                    c.LimiteUsos = datos.Lector["LimiteUsos"] is DBNull ? (int?)null : (int)datos.Lector["LimiteUsos"];
                    c.UsosActuales = (int)datos.Lector["UsosActuales"];
                    // solo necesito el id para preseleccionar el cliente en el combo al editar
                    c.Usuario = new Usuario { IdUsuario = (int)datos.Lector["IDUsuario"] };
                    return c;
                }
                return null;
            }
            catch (Exception)
            {
                throw;
            }
            finally
            {
                datos.CerrarConexion();
            }
        }

        public void Agregar(Cupon c)
        {
            AccesoDatos datos = new AccesoDatos();

            datos.SetearConsulta(@"
                INSERT INTO Cupones
                    (Codigo, Descripcion, IDEstadoCupon, IDTipoDescuento, ValorDescuento,
                     ReservasRequeridas, ValidoDesde, ValidoHasta, LimiteUsos, UsosActuales, IDUsuario)
                VALUES
                    (@codigo, @desc, 1, @tipo, @valor,
                     @reservas, @desde, @hasta, @limite, 0, @usuario)");
            CargarParametros(datos, c);
            datos.EjecutarAccion();
        }

        public void Modificar(Cupon c)
        {
            AccesoDatos datos = new AccesoDatos();

            datos.SetearConsulta(@"
                UPDATE Cupones SET
                    Codigo = @codigo,
                    Descripcion = @desc,
                    IDTipoDescuento = @tipo,
                    ValorDescuento = @valor,
                    ReservasRequeridas = @reservas,
                    ValidoDesde = @desde,
                    ValidoHasta = @hasta,
                    LimiteUsos = @limite,
                    IDUsuario = @usuario
                WHERE IDCupon = @id");
            CargarParametros(datos, c);
            datos.AgregarParametro("@id", c.IdCupon);
            datos.EjecutarAccion();
        }

        public void BajaLogica(int idCupon)
        {
            AccesoDatos datos = new AccesoDatos();

            datos.SetearConsulta("UPDATE Cupones SET IDEstadoCupon = 5 WHERE IDCupon = @id");
            datos.AgregarParametro("@id", idCupon);
            datos.EjecutarAccion();
        }

        // parametros compartidos por Agregar y Modificar (los nullables van como DBNull)
        private void CargarParametros(AccesoDatos datos, Cupon c)
        {
            datos.AgregarParametro("@codigo", c.Codigo);
            datos.AgregarParametro("@desc", c.Descripcion ?? "");
            datos.AgregarParametro("@tipo", (int)c.TipoDescuento);
            datos.AgregarParametro("@valor", (object)c.ValorDescuento ?? DBNull.Value);
            datos.AgregarParametro("@reservas", c.ReservasRequeridas);
            datos.AgregarParametro("@desde", (object)c.ValidoDesde ?? DBNull.Value);
            datos.AgregarParametro("@hasta", (object)c.ValidoHasta ?? DBNull.Value);
            datos.AgregarParametro("@limite", (object)c.LimiteUsos ?? DBNull.Value);
            datos.AgregarParametro("@usuario", c.Usuario.IdUsuario);
        }
    }
}
