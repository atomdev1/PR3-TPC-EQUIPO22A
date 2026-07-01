using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Web.UI.WebControls;
using Dominio;
using Dominio.Enums;
using Negocio;
using System.Linq;
using System.Web.UI;

namespace WebApp
{
    public partial class Cupones : CuponPageBase
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            Usuario u = Session["usuario"] as Usuario;
            if (u == null) { Response.Redirect("~/Login.aspx"); return; }
            if (u.Rol != RolUsuario.Administrador && u.Rol != RolUsuario.Recepcionista)
            {
                Response.Redirect("~/Dashboard.aspx");
                return;
            }

            if (!IsPostBack)
            {
                CargarCupones();
                CargarUsuarios();
            }
        }

        private void CargarCupones()
        {
            NegocioCupones nCupones = new NegocioCupones();
            List<Cupon> lista = nCupones.ObtenerTodas();

            if (ddlFiltroTipo.SelectedValue != "0")
            {
                int tipo = int.Parse(ddlFiltroTipo.SelectedValue);
                lista = lista.Where(c => (int)c.TipoDescuento == tipo).ToList();
            }

            if (ddlFiltroEstado.SelectedValue != "0")
            {
                int estado = int.Parse(ddlFiltroEstado.SelectedValue);
                lista = lista.Where(c => (int)c.Estado == estado).ToList();
            }

            rptCupones.DataSource = lista;
            rptCupones.DataBind();
        }

        protected void Filtrar(Object sender, EventArgs e)
        {
            CargarCupones();
        }
        protected void LimpiarFiltros(Object sender, EventArgs e)
        {
            ddlFiltroTipo.SelectedValue = "0";
            ddlFiltroEstado.SelectedValue = "0";
            CargarCupones();
        }
        private void CargarUsuarios()
        {
            NegocioCupones nCupones = new NegocioCupones();
            List<Usuario> usuarios = nCupones.ObtenerUsuarios();

            foreach (Usuario u in usuarios)
                ddlUsuario.Items.Add(new ListItem(u.Nombre + " " + u.Apellido, u.IdUsuario.ToString()));

            ddlUsuario.Items.Insert(0, new ListItem("-- Seleccioná un cliente --", "0"));
        }

        // Alta: limpia el formulario, deja todo en estado inicial y abre el modal.
        protected void btnNuevoCupon_Click(object sender, EventArgs e)
        {
            hfIdCupon.Value            = "";
            txtCodigo.Text             = "";
            ddlTipoDescuento.SelectedValue = "1";
            txtValorDescuento.Text     = "";
            txtReservasRequeridas.Text = "";
            txtValidoHasta.Text        = "";
            txtLimiteUsos.Text         = "";
            txtDescripcion.Text        = "";
            ddlUsuario.SelectedValue   = "0";
            lblError.Visible           = false;
       
            List<BeneficioFidelidad> beneficios = new NegocioBeneficios().ObtenerActivos();
            ddlBeneficio.DataSource = beneficios;
            ddlBeneficio.DataTextField = "Nombre";
            ddlBeneficio.DataValueField = "IdBeneficio";
            ddlBeneficio.DataBind();
            ddlBeneficio.Items.Insert(0, new ListItem("Cupón personalizado", "0"));
            ddlBeneficio.SelectedValue = "0";

            AplicarEstadoValor();
            AbrirModal("Nuevo cupón");
        }

        // Confirma la baja: anula el cupón del id guardado y oculta el panel.
        protected void btnConfirmarBaja_Click(object sender, EventArgs e)
        {
            new NegocioCupones().BajaLogica(int.Parse(hfBajaId.Value));
            pnlConfirmarBaja.Visible = false;
            CargarCupones();
        }

        protected void btnCancelarBaja_Click(object sender, EventArgs e)
        {
            pnlConfirmarBaja.Visible = false;
        }

        // "Reserva gratis" no lleva valor: se deshabilita el campo (el server igual fuerza NULL).
        // Corre por AutoPostBack dentro del UpdatePanel, así el modal no se cierra.
        protected void ddlTipoDescuento_SelectedIndexChanged(object sender, EventArgs e)
        {
            AplicarEstadoValor();
        }

        protected void ddlBeneficio_SelectedIndexChanged(object sender, EventArgs e)
        {
            if (ddlBeneficio.SelectedValue == "0")
            {
                ddlTipoDescuento.SelectedValue = "1";
                txtValorDescuento.Text = "";
                txtReservasRequeridas.Text = "";
                txtDescripcion.Text = "";

                ddlTipoDescuento.Enabled = true;
                txtValorDescuento.Enabled = true;
                txtReservasRequeridas.Enabled = true;
                txtDescripcion.Enabled = true;

                AplicarEstadoValor();
                return;
            }

            int idBeneficio = int.Parse(ddlBeneficio.SelectedValue);
            BeneficioFidelidad b = new NegocioBeneficios().ObtenerPorId(idBeneficio);
            if (b == null) return;

            ddlTipoDescuento.SelectedValue = ((int)b.TipoDescuento).ToString();
            txtValorDescuento.Text = b.ValorDescuento.HasValue ? b.ValorDescuento.Value.ToString(System.Globalization.CultureInfo.InvariantCulture) : "";
            txtReservasRequeridas.Text = b.ReservasRequeridas.ToString();
            txtDescripcion.Text = b.Descripcion;

            ddlTipoDescuento.Enabled = false;
            txtValorDescuento.Enabled = false;
            txtReservasRequeridas.Enabled = false;
            txtDescripcion.Enabled = false;

        }

        private void AplicarEstadoValor()
        {
            bool esReservaGratis = ddlTipoDescuento.SelectedValue == "2";
            txtValorDescuento.Enabled = !esReservaGratis;
            if (esReservaGratis) txtValorDescuento.Text = "";
        }

        private void AbrirModal(string titulo)
        {
            string script =
                "var lbl = document.getElementById('modalNuevoCuponLabel'); if (lbl) lbl.textContent = '" + titulo + "';" +
                "bootstrap.Modal.getOrCreateInstance(document.getElementById('modalNuevoCupon')).show();";
            ClientScript.RegisterStartupScript(GetType(), "abrirModalCupon", script, true);
        }

        protected void rptCupones_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            int idCupon = int.Parse(e.CommandArgument.ToString());

            if (e.CommandName == "Editar")
            {
                Cupon c = new NegocioCupones().ObtenerPorId(idCupon);
                if (c == null) return;

                hfIdCupon.Value                    = c.IdCupon.ToString();
                txtCodigo.Text                     = c.Codigo;
                ddlTipoDescuento.SelectedValue     = ((int)c.TipoDescuento).ToString();
                txtValorDescuento.Text             = c.ValorDescuento.HasValue ? c.ValorDescuento.Value.ToString(System.Globalization.CultureInfo.InvariantCulture) : "";
                txtReservasRequeridas.Text         = c.ReservasRequeridas.ToString();
                txtValidoHasta.Text                = c.ValidoHasta.HasValue ? c.ValidoHasta.Value.ToString("yyyy-MM-dd") : "";
                txtLimiteUsos.Text                 = c.LimiteUsos.HasValue ? c.LimiteUsos.Value.ToString() : "";
                txtDescripcion.Text                = c.Descripcion;
                ddlUsuario.SelectedValue           = c.Usuario.IdUsuario.ToString();

                AplicarEstadoValor();
                AbrirModal("Editar cupón");
            }
            else if (e.CommandName == "Baja")
            {
                // No se da de baja directo: se pide confirmación con un panel.
                Cupon c = new NegocioCupones().ObtenerPorId(idCupon);
                hfBajaId.Value = idCupon.ToString();
                lblConfirmarBaja.Text = "¿Dar de baja el cupón \"" + (c != null ? c.Codigo : "") + "\"?";
                pnlConfirmarBaja.Visible = true;
            }
            else if (e.CommandName == "Reactivar")
            {
                new NegocioCupones().Reactivar(idCupon);
                CargarCupones();
            }
        }

        protected void btnGuardarCupon_Click(object sender, EventArgs e)
        {
            if (!Page.IsValid) return;

            TipoDescuento tipo = (TipoDescuento)int.Parse(ddlTipoDescuento.SelectedValue);

            // ReservaGratis no lleva valor; el resto sí es obligatorio
            decimal? valorDescuento;
            if (tipo == TipoDescuento.ReservaGratis)
            {
                valorDescuento = null;
            }
            else if (string.IsNullOrEmpty(txtValorDescuento.Text))
            {
                MostrarError("El valor del descuento es obligatorio para este tipo.");
                return;
            }
            else
            {
                valorDescuento = decimal.Parse(txtValorDescuento.Text);
            }

            Cupon cupon = new Cupon
            {
                Codigo = txtCodigo.Text.Trim().ToUpper(),
                TipoDescuento = tipo,
                ValorDescuento = valorDescuento,
                ReservasRequeridas = int.Parse(txtReservasRequeridas.Text),
                ValidoHasta = string.IsNullOrEmpty(txtValidoHasta.Text) ? (DateTime?)null : DateTime.Parse(txtValidoHasta.Text),
                LimiteUsos = string.IsNullOrEmpty(txtLimiteUsos.Text) ? (int?)null : int.Parse(txtLimiteUsos.Text),
                Descripcion = txtDescripcion.Text.Trim(),
                Usuario = new Usuario { IdUsuario = int.Parse(ddlUsuario.SelectedValue) }
            };

            try
            {
                NegocioCupones nCupones = new NegocioCupones();
                if (string.IsNullOrEmpty(hfIdCupon.Value))
                {
                    cupon.UsosActuales = 0;
                    cupon.Estado = EstadoCupon.Activo;
                    nCupones.Agregar(cupon);
                }
                else
                {
                    cupon.IdCupon = int.Parse(hfIdCupon.Value);
                    nCupones.Modificar(cupon);
                }
                Response.Redirect("Cupones.aspx");
            }
            catch (SqlException ex) when (ex.Number == 2627 || ex.Number == 2601)
            {
                // violación del UNIQUE de Codigo
                MostrarError("Ya existe un cupón con ese código. Usá uno distinto.");
            }
        }

        private void MostrarError(string mensaje)
        {
            lblError.Text = mensaje;
            lblError.Visible = true;

            // el modal se cierra con el postback, hay que reabrirlo para que se vea el error
            string titulo = string.IsNullOrEmpty(hfIdCupon.Value) ? "Nuevo cupón" : "Editar cupón";
            AbrirModal(titulo);
        }

    }
}
