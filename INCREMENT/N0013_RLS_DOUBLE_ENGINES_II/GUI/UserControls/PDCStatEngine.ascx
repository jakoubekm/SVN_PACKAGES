<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="PDCStatEngine.ascx.cs" Inherits="PDC.UserControls.PDCStatEngine" %>
<div class="PDCSchStatus rightMe">
<asp:UpdatePanel ID="AJAXUpdatePanelStatEng" runat="server">
<ContentTemplate> 

<asp:LinkButton ID="lb_StatENG_Toggle" runat="server" CssClass="headerButton" EnableViewState="False" onclick="Button_Toggle_Click">Engine</asp:LinkButton>
    <asp:Label ID="l_StatENG_NUMBER_ON" runat="server" Text="" EnableViewState="False"></asp:Label>On
    <asp:Label ID="l_StatENG_NUMBER_OFF" runat="server" Text="" EnableViewState="False"></asp:Label>Off

   
    <asp:Panel ID="p_StatusEngineDetail" runat="server" CssClass="" Visible="False">
        <div class="breaker_portlet">
            &nbsp;</div>
        <asp:GridView ID="GridView1" runat="server" DataSourceID="SqlDataSource_GUI_ENG_STAT"
            GridLines="None" CssClass="PDCTbl" CellPadding="2" CellSpacing="1" 
            EnableViewState="False" AutoGenerateColumns="False">
            <RowStyle CssClass="PDCTblRow" Wrap="False" />
            <SelectedRowStyle CssClass="PDCTblSelRow" />
            <SortedAscendingHeaderStyle CssClass="sort_asc" />
            <SortedDescendingHeaderStyle CssClass="sort_desc" />
            <AlternatingRowStyle CssClass="PDCTblEvenRow" />
            <HeaderStyle CssClass="PDCTblHeader" />
            <Columns>
                <asp:BoundField DataField="PARAM_CD" HeaderText="Engine#" />
                <asp:BoundField DataField="ENG_STATUS" HeaderText="Status" />
            </Columns>
            <FooterStyle CssClass="PDCTblFooter" />
        </asp:GridView>
    </asp:Panel>

    <asp:Timer ID="TimerStatEng" runat="server" 
    Interval="<%$ AppSettings:DefaultPageReloadTimer %>" 
    ontick="TimerStatEng_Tick">
    </asp:Timer>
</ContentTemplate>
</asp:UpdatePanel> 
    </div>
    <asp:SqlDataSource ID="SqlDataSource_GUI_ENG_STAT" runat="server" ConnectionString="<%$ ConnectionStrings:PDCOracleConnection.connectionString %>"
        
    ProviderName="<%$ ConnectionStrings:PDCOracleConnection.ProviderName %>" SelectCommand="PCKG_GUI.SP_GUI_HEADER_ENG_STAT"
        SelectCommandType="StoredProcedure" 
    OnSelected="SqlDataSource_Procedure_Selected" 
    onselecting="SqlDataSource_Procedure_Selecting" EnableViewState="False">
        <SelectParameters>
            <asp:Parameter Name="ENG_STATUS_OUT" Direction="Output" />
            <asp:Parameter Name="ENG_NUMBER_ON" Direction="Output" DbType="String" Size="255" />
            <asp:Parameter Name="ENG_NUMBER_OFF" Direction="Output" DbType="String" Size="255" />
            <asp:Parameter Name="SELECTED_ENG_ID_IN" Direction="InputOutput" DefaultValue="0" DbType="String" Size="255" />
            <asp:Parameter Name="DEBUG_IN" Direction="Input" DefaultValue="0" DbType="String" />
            <asp:Parameter Name="EXIT_CD_OUT" Direction="Output" DbType="String" Size="255" />
            <asp:Parameter Name="ERRMSG_OUT" Direction="Output" DbType="String" Size="255" />
            <asp:Parameter Name="ERRCODE_OUT" Direction="Output" DbType="String" Size="255" />
            <asp:Parameter Name="ERRLINE_OUT" Direction="Output" DbType="String" Size="255" />
        </SelectParameters>
    </asp:SqlDataSource>

