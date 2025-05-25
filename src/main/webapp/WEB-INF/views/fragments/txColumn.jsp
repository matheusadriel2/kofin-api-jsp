<%@ taglib prefix="c"  uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>

<%-- Espera: title, listName, type ---------------------------------------- --%>
<c:set var="txList" value="${requestScope[param.listName]}" />

<div class="col-md-4">
    <div class="d-flex justify-content-between align-items-center mb-2">
        <h6 class="mb-0">${param.title}</h6>
        <button class="btn btn-sm btn-outline-light rounded-circle p-0"
                style="width:28px;height:28px;line-height:26px"
                data-bs-toggle="modal" data-bs-target="#newTxModal"
                data-type="${param.type}">+</button>
    </div>

    <div class="bg-dark bg-opacity-25 rounded p-3 tx-block">
        <c:forEach items="${txList}" var="t">
            <div class="tx-item position-relative border-bottom py-2"
                 data-id="${t.id}"
                 data-name="${t.name}"
                 data-cat="${t.category}"
                 data-val="${t.value}"
                 data-pm ="${t.payMethod}"
                 data-date="${t.transactionDate}"
                 data-type="${param.type}"
                 data-card="${t.cardId}">

                <div class="d-flex">
                    <!-- ===== ESQUERDA ===== -->
                    <div class="flex-grow-1">
                        <!-- nome (máx 30) -->
                        <strong class="d-block">
                                ${fn:length(t.name) > 30 ? fn:substring(t.name,0,30) : t.name}
                            <c:if test="${fn:length(t.name) > 30}">&hellip;</c:if>
                        </strong>

                        <!-- categoria -->
                        <c:if test="${not empty t.category}">
                            <small class="d-block text-muted">${t.category}</small>
                        </c:if>

                        <!-- valor -->
                        <span class="fw-semibold">R$ ${t.value}</span>

                        <!-- método / cartão -->
                        <small class="d-block text-muted">
                            <c:choose>
                                <c:when test="${t.payMethod == 'CARD'}">
                                    CARD&nbsp;-&nbsp;****<c:forEach items="${cards}" var="cd">
                                    <c:if test="${cd.id == t.cardId}">${cd.last4}</c:if>
                                </c:forEach>
                                </c:when>
                                <c:otherwise>${t.payMethod}</c:otherwise>
                            </c:choose>
                        </small>
                    </div>

                    <!-- ===== DIREITA (data/hora) ===== -->
                    <div class="text-end ms-2" style="min-width:72px">
                        <small class="text-secondary">
                                ${fn:substring(t.transactionDate,11,16)}<br/>
                                ${fn:substring(t.transactionDate,8,10)}/${fn:substring(t.transactionDate,5,7)}/${fn:substring(t.transactionDate,2,4)}
                        </small>
                    </div>
                </div>

                <!-- botões flutuantes -->
                <div class="tx-actions position-absolute top-0 end-0 me-1 mt-1 opacity-0">
                    <button class="btn btn-sm btn-outline-light me-1"
                            data-bs-toggle="modal" data-bs-target="#editTxModal"
                            data-id="${t.id}" data-type="${param.type}" data-cardid="${t.cardId}">✎</button>

                    <form class="d-inline" method="post"
                          action="${pageContext.request.contextPath}/transaction"
                          onmousedown="event.stopPropagation()">
                        <input type="hidden" name="action" value="delete"/>
                        <input type="hidden" name="id"     value="${t.id}"/>
                        <button class="btn btn-sm btn-outline-danger">🗑</button>
                    </form>
                </div>
            </div>
        </c:forEach>
    </div>
</div>
