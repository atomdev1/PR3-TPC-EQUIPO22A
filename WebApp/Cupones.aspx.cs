using System;
using System.Collections.Generic;
using System.Web.UI.WebControls;
using Dominio;
using Dominio.Enums;

namespace WebApp
{
    public partial class Cupones : System.Web.UI.Page
    {
        protected Repeater rptCupones;
        protected TextBox txtCodigo;
        protected DropDownList ddlTipoDescuento;
        protected TextBox txtValorDescuento;
        protected TextBox txtReservasRequeridas;
        protected TextBox txtValidoHasta;
        protected TextBox txtLimiteUsos;
        protected TextBox txtDescripcion;
        protected Button btnGuardarCupon;


        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                CargarCupones();
            }
        }

        private void CargarCupones()
        {
            List<Cupon> cupones = new List<Cupon>
            {
                new Cupon { IdCupon = 1, Codigo = "TP-PROMO010", TipoDescuento = TipoDescuento.Porcentaje, ValorDescuento = 10, Descripcion = "10% off para clientes con 3+ reservas", ReservasRequeridas = 3, ValidoHasta = new DateTime(2026, 6, 30), LimiteUsos = 50, UsosActuales = 0, Estado = EstadoCupon.Activo },
                new Cupon { IdCupon = 2, Codigo = "TP-GRATIS", TipoDescuento = TipoDescuento.ReservaGratis, ValorDescuento = null, Descripcion = "Una reserva completamente gratis por acumular 20 reservas", ReservasRequeridas = 20, ValidoHasta = new DateTime(2026, 12, 31), LimiteUsos = 50, UsosActuales = 3, Estado = EstadoCupon.Activo },
                new Cupon { IdCupon = 3, Codigo = "TP-FIDELIDAD15", TipoDescuento = TipoDescuento.Porcentaje, ValorDescuento = 15, Descripcion = "15% de descuento en tu próxima reserva por ser cliente fiel", ReservasRequeridas = 10, ValidoHasta = new DateTime(2026, 12, 31), LimiteUsos = 100, UsosActuales = 12, Estado = EstadoCupon.Activo },
                new Cupon { IdCupon = 4, Codigo = "TP-TURNO200", TipoDescuento = TipoDescuento.MontoFijo, ValorDescuento = 200, Descripcion = "$200 de descuento en tu próximo turno", ReservasRequeridas = 5, ValidoHasta = new DateTime(2026, 12, 31), LimiteUsos = 200, UsosActuales = 45, Estado = EstadoCupon.Activo },
            };

            rptCupones.DataSource = cupones;
            rptCupones.DataBind();
        }

        protected void rptCupones_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            int idCupon = int.Parse(e.CommandArgument.ToString());

            if (e.CommandName == "Editar")
            {
                // HACER: abrir modal de edición con los datos del cupón
            }
            else if (e.CommandName == "Eliminar")
            {
                // HACER: llamar a la capa Negocio para eliminar el cupón
                Response.Redirect("Cupones.aspx");
            }
        }

        protected void btnGuardarCupon_Click(object sender, EventArgs e)
        {
            Cupon cupon = new Cupon
            {
                Codigo = txtCodigo.Text.Trim().ToUpper(),
                TipoDescuento = (TipoDescuento)int.Parse(ddlTipoDescuento.SelectedValue),
                ValorDescuento = decimal.Parse(txtValorDescuento.Text),
                ReservasRequeridas = int.Parse(txtReservasRequeridas.Text),
                ValidoHasta = string.IsNullOrEmpty(txtValidoHasta.Text) ? (DateTime?)null : DateTime.Parse(txtValidoHasta.Text),
                LimiteUsos = string.IsNullOrEmpty(txtLimiteUsos.Text) ? (int?)null : int.Parse(txtLimiteUsos.Text),
                Descripcion = txtDescripcion.Text.Trim(),
                UsosActuales = 0,
                Estado = EstadoCupon.Activo
            };

            // HACER: llamar a la capa Negocio para guardar el cupón
            Response.Redirect("Cupones.aspx");
        }

        protected string GetBadgeSymbol(object tipoDescuentoObj)
        {
            TipoDescuento tipo = (TipoDescuento)tipoDescuentoObj;
            return tipo == TipoDescuento.Porcentaje ? "%" : "$";
        }

        protected string GetBadgeClass(object tipoDescuentoObj)
        {
            TipoDescuento tipo = (TipoDescuento)tipoDescuentoObj;
            return tipo == TipoDescuento.MontoFijo ? "monto-fijo" : "";
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
            if (valorObj == null || valorObj == DBNull.Value) return "-";
            decimal valor = Convert.ToDecimal(valorObj);
            TipoDescuento tipo = (TipoDescuento)tipoDescuentoObj;
            if (tipo == TipoDescuento.Porcentaje)
                return valor == 100 ? "100% OFF" : $"{valor:0}% OFF";
            return $"${valor:0} OFF";
        }

        protected string FormatearMeta(string tipo, object val1, object val2 = null)
        {
            switch (tipo)
            {
                case "reservas":
                    return "Requiere " + val1 + " reservas";
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
