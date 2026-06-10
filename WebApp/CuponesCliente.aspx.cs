using System;
using System.Collections.Generic;
using System.Linq;
using System.Web.UI.WebControls;
using Dominio;
using Dominio.Enums;
using Negocio;

namespace WebApp
{
    public partial class CuponesCliente : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            // El Page_Load de la página corre ANTES que el del Site.Master, así que
            // su redirect no nos cubre: el guard de sesión va acá mismo.
            // HACER: control de acceso por rol — pendiente cambio de roles (guard centralizado futuro)
            if (Session["usuario"] == null)
            {
                Response.Redirect("~/Login.aspx");
                return;
            }

            if (!IsPostBack)
                CargarCupones();
        }

        // Reservas acumuladas del cliente logueado. La usan los helpers de progreso
        // del Repeater de objetivos para preguntarle a cada beneficio "¿cuánto falta?".
        protected int reservasCliente;

        private void CargarCupones()
        {
            Usuario usuario = (Usuario)Session["usuario"];
            reservasCliente = usuario.CantidadAsistencias;

            List<Cupon> cupones = new NegocioCupones().ObtenerPorUsuario(usuario.IdUsuario);

            // Usables ahora vs historial (canjeados / vencidos / agotados)
            List<Cupon> disponibles = cupones.Where(c => c.Estado == EstadoCupon.Activo).ToList();
            List<Cupon> historial = cupones.Where(c => c.Estado != EstadoCupon.Activo).ToList();

            rptDisponibles.DataSource = disponibles;
            rptDisponibles.DataBind();
            rptHistorial.DataSource = historial;
            rptHistorial.DataBind();

            // Objetivos "en camino": beneficios del catálogo que el cliente todavía no alcanzó.
            // El cupón real recién existe cuando el trigger lo materialice al llegar al umbral.
            List<BeneficioFidelidad> objetivos = new NegocioBeneficios()
                .ObtenerActivos()
                .Where(b => !b.YaAlcanzado(reservasCliente))
                .ToList();

            rptObjetivos.DataSource = objetivos;
            rptObjetivos.DataBind();

            pnlVacio.Visible = cupones.Count == 0 && objetivos.Count == 0;
            pnlDisponibles.Visible = cupones.Count > 0;
            pnlSinDisponibles.Visible = cupones.Count > 0 && disponibles.Count == 0;
            pnlHistorial.Visible = historial.Count > 0;
            pnlObjetivos.Visible = objetivos.Count > 0;

            lblTotal.Text = disponibles.Count == 1
                ? "1 cupón disponible"
                : disponibles.Count + " cupones disponibles";
        }

        // ── Helpers del Repeater de objetivos: delegan en el comportamiento del dominio ──

        protected string TextoFaltantes(object beneficioObj)
        {
            int faltan = ((BeneficioFidelidad)beneficioObj).ReservasFaltantes(reservasCliente);
            return faltan == 1
                ? "Te falta 1 reserva"
                : "Te faltan " + faltan + " reservas";
        }

        protected int ProgresoPorcentaje(object beneficioObj)
        {
            return ((BeneficioFidelidad)beneficioObj).PorcentajeProgreso(reservasCliente);
        }

        protected string ProgresoFraccion(object beneficioObj)
        {
            return reservasCliente + " / " + ((BeneficioFidelidad)beneficioObj).ReservasRequeridas;
        }

        // ── Helpers de presentación (reutilizados de Cupones.aspx.cs) ──────────

        protected string GetBadgeSymbol(object tipoDescuentoObj)
        {
            TipoDescuento tipo = (TipoDescuento)tipoDescuentoObj;
            return tipo == TipoDescuento.Porcentaje ? "%" : "$";
        }

        protected string GetTipoNombre(object tipoDescuentoObj)
        {
            TipoDescuento tipo = (TipoDescuento)tipoDescuentoObj;
            return tipo == TipoDescuento.ReservaGratis ? "Reserva gratis" : "Descuento en reserva";
        }

        protected string GetEstadoBadgeClass(object estadoObj)
        {
            EstadoCupon estado = (EstadoCupon)estadoObj;
            switch (estado)
            {
                case EstadoCupon.Activo: return "text-success bg-success-subtle";
                case EstadoCupon.Canjeado: return "text-secondary bg-secondary-subtle";
                case EstadoCupon.Vencido: return "text-warning bg-warning-subtle";
                case EstadoCupon.Agotado: return "text-danger bg-danger-subtle";
                default: return "text-secondary bg-secondary-subtle";
            }
        }

        protected string FormatearValor(object tipoDescuentoObj, object valorObj)
        {
            TipoDescuento tipo = (TipoDescuento)tipoDescuentoObj;
            if (tipo == TipoDescuento.ReservaGratis) return "GRATIS";
            if (valorObj == null || valorObj == DBNull.Value) return "-";
            decimal valor = Convert.ToDecimal(valorObj);
            return valor == 100 ? "100% OFF" : $"{valor:0}% OFF";
        }

        protected string FormatearMeta(string tipo, object val1, object val2 = null)
        {
            switch (tipo)
            {
                case "reservas":
                    return "🎯 Obtenido con " + val1 + " reservas";
                case "fecha":
                    if (val1 == null || val1 == DBNull.Value) return "Sin vencimiento";
                    return "Válido hasta: " + Convert.ToDateTime(val1).ToString("yyyy-MM-dd");
                case "usos":
                    string limite = (val2 == null || val2 == DBNull.Value) ? "∞" : val2.ToString();
                    return "Usado: " + val1 + "/" + limite + " veces";
                default:
                    return "";
            }
        }
    }
}
